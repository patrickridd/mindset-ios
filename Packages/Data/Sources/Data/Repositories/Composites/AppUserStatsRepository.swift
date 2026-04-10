//
//  AppUserStatsRepository.swift
//  Data
//
//  Created by patrick ridd on 4/9/26.
//


import Foundation
import Domain

@MainActor
public final class AppUserStatsRepository: UserStatsRepository {
    private let localStore: UserStatsRepository
    private let remoteStore: UserStatsRepository
    private let logger: AppLogger

    public init(
        local: UserStatsRepository,
        remote: UserStatsRepository,
        logger: AppLogger
    ) {
        self.localStore = local
        self.remoteStore = remote
        self.logger = logger
    }

    public func fetchStats(userId: String) async throws -> UserStats? {
        // High-scale strategy: Always serve from local cache for instant UI
        try await localStore.fetchStats(userId: userId)
    }

    public func updateStats(userId: String, xpDelta: Int, newStreak: Int) async throws {
        // 1. Update Local (SwiftData) - This makes the UI reflect the change immediately
        try await localStore.updateStats(userId: userId, xpDelta: xpDelta, newStreak: newStreak)

        // 2. Fire-and-Forget Remote Sync
        // We use Task to ensure the ritual completion isn't blocked by network latency
        Task {
            do {
                try await remoteStore.updateStats(userId: userId, xpDelta: xpDelta, newStreak: newStreak)
                logger.log("☁️ Stats synced to Firestore: +\(xpDelta) XP, Streak: \(newStreak)")
            } catch {
                logger.log("⚠️ Remote Stats sync pending (Offline): \(error.localizedDescription)")
            }
        }
    }

    public func incrementTotalXP(userId: String, by amount: Int) async throws {
        // Update local first
        try await localStore.incrementTotalXP(userId: userId, by: amount)

        // Sync to remote
        Task {
            do {
                try await remoteStore.incrementTotalXP(userId: userId, by: amount)
            } catch {
                logger.log("⚠️ Remote XP increment pending: \(error.localizedDescription)")
            }
        }
    }
}