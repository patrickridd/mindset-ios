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
        let local = try await localStore.fetchUserProfile()
        
        Task {
            guard let uid = await authStateQuery.getCurrentUserID() else {
                logger.log("📵 Not signed in, skipping sync")
                return
            }
            do {
                if let remote = try await remoteStore.fetchRemoteProfile(uid: uid) {
                    await resolveSync(local: local, remote: remote)
                }
            } catch {
                logger.log("☁️ Sync failed: \(error.localizedDescription)")
            }
        }
        
        return local
    }

    @MainActor
    private func resolveSync(local: UserProfile?, remote: UserProfile) async {
        guard let local = local else {
            // New device: Bootstrap local from remote
            try? await localStore.saveUserProfile(remote)
            return
        }
        
        if remote.lastUpdatedAt > local.lastUpdatedAt {
            // Cloud is newer: Update local
            try? await localStore.saveUserProfile(remote)
            // 📢 Trigger that .databaseDidChange notification to refresh UI!
            notificationCenter.post(name: .databaseDidChange, object: nil)
        } else if local.lastUpdatedAt > remote.lastUpdatedAt {
            // Local is newer: Push to cloud
            try? await remoteStore.uploadProfile(local)
        }
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        // 1. Update the timestamp locally
        var updatedProfile = profile
        updatedProfile.lastUpdatedAt = Date()
        
        // 2. Save locally (SwiftData)
        try await localStore.saveUserProfile(updatedProfile)
        
        // 3. Firebase handles the 'push' whenever connectivity is restored
        try await remoteStore.uploadProfile(updatedProfile)
    }
    
    public func isOnboardingComplete() async -> Bool {
        await localStore.isOnboardingComplete()
    }
}
