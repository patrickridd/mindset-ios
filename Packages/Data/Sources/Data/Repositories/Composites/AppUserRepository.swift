//
//  AppUserRepository.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//

import Foundation
import Domain

public final class AppUserRepository: UserRepository {
    private let localStore: UserRepository
    private let remoteStore: RemoteUserRepository
    private let authStateQuery: AuthStateQuery
    private let logger: AppLogger
    private let notificationCenter: NotificationCenter
    
    public init(local: UserRepository, remote: RemoteUserRepository, authStateQuery: AuthStateQuery, logger: AppLogger, notificationCenter: NotificationCenter = .default) {
        self.localStore = local
        self.remoteStore = remote
        self.authStateQuery = authStateQuery
        self.logger = logger
        self.notificationCenter = notificationCenter
    }

    public func fetchUserProfile() async throws -> UserProfile? {
        let localUser = try await localStore.fetchUserProfile()
        
        Task {
            guard let uid = await authStateQuery.getCurrentUserID() else {
                logger.log("📵 Not signed in, skipping sync")
                return
            }
            do {
                if let remoteUser = try await remoteStore.fetchRemoteProfile(uid: uid) {
                    await resolveSync(localUser: localUser, remoteUser: remoteUser)
                }
            } catch {
                logger.log("☁️ Sync failed: \(error.localizedDescription)")
            }
        }
        
        return localUser
    }

    @MainActor
    private func resolveSync(localUser: UserProfile?, remoteUser: UserProfile?) async {
        // 1. If we have a remote profile, compare and update
        if let remote = remoteUser {
            if localUser == nil {
                // New device bootstrap
                try? await localStore.saveUserProfile(remote)
                notificationCenter.post(name: .databaseDidChange, object: nil)
            } else if remote.lastUpdatedAt > localUser!.lastUpdatedAt {
                // Cloud is newer
                try? await localStore.saveUserProfile(remote)
                notificationCenter.post(name: .databaseDidChange, object: nil)
            } else if localUser!.lastUpdatedAt > remote.lastUpdatedAt {
                // Local is newer
                try? await remoteStore.uploadProfile(localUser!)
            }
        } else {
            // 2. If remote is NIL and local is NIL, we need to ensure
            // that the 'Parent' document is created at least once.
            if localUser == nil, let uid = await authStateQuery.getCurrentUserID() {
                let placeholder = UserProfile.anonymousUser(id: uid)
                try? await saveUserProfile(placeholder)
            }
        }
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        // 1. Update the timestamp locally
        var updatedProfile = profile
        updatedProfile.lastUpdatedAt = Date()
        
        // 2. Save locally (SwiftData) - INSTANT
        try await localStore.saveUserProfile(updatedProfile)
        
        // 3. FIRE-AND-FORGET Remote Sync
        // We wrap this in a Task so it doesn't 'await' the network response.
        // Firebase SDK will internally queue this write even if the user is offline.
        Task {
            do {
                try await remoteStore.uploadProfile(updatedProfile)
                logger.log("☁️ Profile successfully queued/synced to Firestore")
            } catch {
                // We log it, but we DON'T throw, because the local save was successful.
                logger.log("⚠️ Remote profile sync queued (Offline/Error): \(error.localizedDescription)")
            }
        }
    }
    
    public func isOnboardingComplete() async -> Bool {
        await localStore.isOnboardingComplete()
    }
}
