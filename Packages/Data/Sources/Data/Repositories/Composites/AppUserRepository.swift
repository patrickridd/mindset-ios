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
    
    // MARK: - UserRepository

    public func fetchUser() async throws -> User? {
        // JUST return the local data.
        try await localStore.fetchUser()
    }

    public func saveUser(_ profile: User) async throws {
        // Cancel any background 'Sync' that might be trying to pull
        // older data from the cloud while we are trying to save NEW data.
        syncTask?.cancel()
        syncTask = nil
        
        // Update the timestamp locally
        var updatedProfile = profile
        updatedProfile.lastUpdatedAt = Date()
        
        // Save locally (SwiftData) - INSTANT
        try await localStore.saveUser(updatedProfile)
        
        // FIRE-AND-FORGET Remote Sync
        // We wrap this in a Task so it doesn't 'await' the network response.
        // Firebase SDK will internally queue this write even if the user is offline.
        Task {
            do {
                try await remoteStore.saveUser(updatedProfile)
                logger.log("☁️ Profile successfully queued/synced to Firestore")
            } catch {
                // We log it, but we DON'T throw, because the local save was successful.
                logger.log("⚠️ Remote profile sync queued (Offline/Error): \(error.localizedDescription)")
            }
        }
    }

    public func deleteUser() async throws {
        // 1. Kill the cloud first (while we still have Auth tokens)
        try await remoteStore.deleteUser()
        
        // 2. Kill the local cache
        try await localStore.deleteUser()

        logger.log("🗑️ AppUserRepository: Local and Remote profiles purged.")
    }

    public func isOnboardingComplete() async -> Bool {
        await localStore.isOnboardingComplete()
    }
}
