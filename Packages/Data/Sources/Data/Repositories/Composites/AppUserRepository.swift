//
//  AppUserRepository.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//

import Foundation
import Domain

@MainActor
public final class AppUserRepository: UserRepository {
    private let localStore: UserRepository
    private let remoteStore: UserRepository
    private let authStateQuery: AuthStateQuery
    private let logger: AppLogger
    private let notificationCenter: NotificationCenter
    private var syncTask: Task<Void, Never>?
    
    private var isSyncing: Bool {
        syncTask != nil
    }
    
    public init(local: UserRepository, remote: UserRepository, authStateQuery: AuthStateQuery, logger: AppLogger, notificationCenter: NotificationCenter = .default) {
        self.localStore = local
        self.remoteStore = remote
        self.authStateQuery = authStateQuery
        self.logger = logger
        self.notificationCenter = notificationCenter
    }
    
    public func fetchUserProfile() async throws -> UserProfile? {
        let localUser = try await localStore.fetchUserProfile()
        
        // Only start a new sync if one isn't already running
        if isSyncing {
            return localUser
        }

        // Only start a new sync if one isn't already running
        syncTask = Task {
            defer { syncTask = nil } // Clear the task when done
            
            // Check for cancellation before starting network work
            if Task.isCancelled { return }
            
            guard let uid = await authStateQuery.getCurrentUserID() else {
                logger.log("📵 Not signed in, skipping sync")
                return
            }
            do {
                if let remoteUser = try await remoteStore.fetchUserProfile() {
                    // Check again before we write to local store
                    try Task.checkCancellation()
                    await resolveSync(localUser: localUser, remoteUser: remoteUser)
                } else if let localUser {
                    try Task.checkCancellation()
                    logger.log("🛠 Sync: No remote found. Uploading local to create Firestore anchor...")
                    try await remoteStore.saveUserProfile(localUser)
                }
            } catch is CancellationError {
                logger.log("Sync cancelled: User initiated a newer save.")
            } catch {
                logger.log("☁️ Sync failed: \(error.localizedDescription)")
            }
        }

        return localUser
    }

    private func resolveSync(localUser: UserProfile?, remoteUser: UserProfile?) async {
        // 1. Identify the current user session
        guard let uid = await authStateQuery.getCurrentUserID() else {
            logger.log("📵 Sync aborted: No authenticated UID found.")
            return
        }
        
        // 2. Map the data state to a specific SyncState
        let state = SyncState(localUser: localUser, remoteUser: remoteUser, uid: uid)

        // 3. Execute the strategy based on the state
        switch state {
        case .newUserCreation(let uid):
            logger.log("🆕 Sync: Creating initial profile for new user.")
            let placeholder = UserProfile.anonymousUser(id: uid)
            try? await saveUserProfile(placeholder)

        case .remoteOnly(let remote):
            logger.log("☁️ Sync: Bootstrapping local store from Cloud.")
            await updateLocal(with: remote)

        case .localOnly(let local):
            logger.log("🛠 Sync: Uploading local-only profile to Cloud.")
            try? await remoteStore.saveUserProfile(local)

        case .resolve(let local, let remote):
            if remote.lastUpdatedAt > local.lastUpdatedAt {
                logger.log("🔄 Sync: Cloud is newer. Updating local.")
                await updateLocal(with: remote)
            } else if local.lastUpdatedAt > remote.lastUpdatedAt {
                logger.log("🔄 Sync: Local is newer. Updating cloud.")
                try? await remoteStore.saveUserProfile(local)
            } else {
                logger.log("✅ Sync: Local and Cloud are already identical.")
            }
        }
    }

    private func updateLocal(with remote: UserProfile) async {
        try? await localStore.saveUserProfile(remote)
        notificationCenter.post(name: .databaseDidChange, object: nil)
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        // Cancel any background 'Sync' that might be trying to pull
        // older data from the cloud while we are trying to save NEW data.
        syncTask?.cancel()
        syncTask = nil
        
        // Update the timestamp locally
        var updatedProfile = profile
        updatedProfile.lastUpdatedAt = Date()
        
        // Save locally (SwiftData) - INSTANT
        try await localStore.saveUserProfile(updatedProfile)
        
        // FIRE-AND-FORGET Remote Sync
        // We wrap this in a Task so it doesn't 'await' the network response.
        // Firebase SDK will internally queue this write even if the user is offline.
        Task {
            do {
                try await remoteStore.saveUserProfile(updatedProfile)
                logger.log("☁️ Profile successfully queued/synced to Firestore")
            } catch {
                // We log it, but we DON'T throw, because the local save was successful.
                logger.log("⚠️ Remote profile sync queued (Offline/Error): \(error.localizedDescription)")
            }
        }
    }

    public func deleteProfile() async throws {
        // 1. Kill the cloud first (while we still have Auth tokens)
        try await remoteStore.deleteProfile()
        
        // 2. Kill the local cache
        try await localStore.deleteProfile()

        logger.log("🗑️ AppUserRepository: Local and Remote profiles purged.")
    }

    public func isOnboardingComplete() async -> Bool {
        await localStore.isOnboardingComplete()
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
