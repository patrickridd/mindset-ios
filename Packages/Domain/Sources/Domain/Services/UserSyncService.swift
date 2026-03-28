//
//  UserSyncService.swift
//  Domain
//
//  Created by patrick ridd on 3/20/26.
//

import Foundation

@MainActor
public final class UserSyncService: Sendable {
    private let localStore: UserRepository      // SwiftData
    private let remoteStore: UserRepository     // Firestore
    private let authService: AuthService
    private let notificationCenter: NotificationCenter
    private let logger: AppLogger

    public init(
        localStore: UserRepository,
        remoteStore: UserRepository,
        authService: AuthService,
        notificationCenter: NotificationCenter = .default,
        logger: AppLogger
    ) {
        self.localStore = localStore
        self.remoteStore = remoteStore
        self.authService = authService
        self.notificationCenter = notificationCenter
        self.logger = logger
    }

    public func syncUserOnLaunch() async {
        guard let uid = await authService.getCurrentUserID() else {
            logger.log("🚪 No UID found, skipping launch sync.")
            return
        }

        do {
            // 1. Fetch current states from both worlds
            let localUser = try await localStore.fetchUserProfile()
            let remoteUser = try await remoteStore.fetchUserProfile()

            // 2. Identify the situation using your SyncState enum
            let state = SyncState(localUser: localUser, remoteUser: remoteUser, uid: uid)

            // 3. Resolve the state
            switch state {
            case .newUserCreation(let uid):
                logger.log("✨ Provisioning brand new user anchor.")
                let newProfile = UserProfile.anonymousUser(id: uid)
                try await localStore.saveUserProfile(newProfile)
                try await remoteStore.saveUserProfile(newProfile)

            case .remoteOnly(let remote):
                logger.log("☁️ Bootstrapping local store from Cloud.")
                try await localStore.saveUserProfile(remote)
                notificationCenter.post(name: .databaseDidChange, object: nil)

            case .localOnly(let local):
                logger.log("🛠 Uploading local profile to Cloud anchor.")
                try await remoteStore.saveUserProfile(local)

            case .resolve(let local, let remote):
                try await handleComparison(local: local, remote: remote)
            }

            logger.log("✅ User Sync Sequence Completed.")
        } catch {
            logger.log("⚠️ User Sync failed: \(error.localizedDescription)")
        }
    }

    private func handleComparison(local: UserProfile, remote: UserProfile) async throws {
        // Use a 1-second leeway to ignore nanosecond jitter between DBs
        let timeDiff = abs(remote.lastUpdatedAt.timeIntervalSince(local.lastUpdatedAt))
        
        if timeDiff < 1.0 {
            logger.log("✅ Sync: Profiles are already in parity.")
            return
        }

        if remote.lastUpdatedAt > local.lastUpdatedAt {
            logger.log("🔄 Sync: Cloud is newer. Updating local.")
            try await localStore.saveUserProfile(remote)
            notificationCenter.post(name: .databaseDidChange, object: nil)
        } else {
            logger.log("🔄 Sync: Local is newer. Updating cloud.")
            try await remoteStore.saveUserProfile(local)
        }
    }
}

private enum SyncState {
    case newUserCreation(uid: String)
    case remoteOnly(remote: UserProfile)
    case localOnly(local: UserProfile)
    case resolve(local: UserProfile, remote: UserProfile)

    init(localUser: UserProfile?, remoteUser: UserProfile?, uid: String) {
        switch (localUser, remoteUser) {
        // 1. Total Void: New User / First Sign In
        case (nil, nil):
            self = .newUserCreation(uid: uid)
        // 2. New Device / Data Recovery: Remote exists, Local doesn't
        case (nil, .some(let remoteUser)):
            self = .remoteOnly(remote: remoteUser)
        // 3. First-time Upload: Local exists, Remote doesn't (or document was deleted)
        case (.some(let localUser), nil):
            self = .localOnly(local: localUser)
        // 4. Comparison: Both exist, may the newest timestamp win
        case (.some(let localUser), .some(let remoteUser)):
            self = .resolve(local: localUser, remote: remoteUser)
        }
    }
}
