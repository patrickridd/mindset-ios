//
//  SDUserStatsRepository.swift
//  Data
//
//  Created by patrick ridd on 4/9/26.
//


import Domain
import Foundation
import SwiftData

@MainActor
public final class SDUserStatsRepository: UserStatsRepository {
    private let modelContext: ModelContext
    private let logger: AppLogger

    public init(modelContext: ModelContext, logger: AppLogger) {
        self.modelContext = modelContext
        self.logger = logger
    }

    public func fetchStats(userId: String) async throws -> UserStats? {
        let descriptor = FetchDescriptor<SDUserStats>(
            predicate: #Predicate<SDUserStats> { $0.userId == userId }
        )
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    public func updateStats(userId: String, xpDelta: Int, newStreak: Int) async throws {
        let descriptor = FetchDescriptor<SDUserStats>(
            predicate: #Predicate<SDUserStats> { $0.userId == userId }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            existing.totalXP += xpDelta
            existing.currentStreak = newStreak
            existing.lastUpdated = Date()
            logger.log("📊 SDStats: Updated XP +\(xpDelta) and Streak \(newStreak)")
        } else {
            let newStats = SDUserStats(userId: userId, currentStreak: newStreak, totalXP: xpDelta)
            modelContext.insert(newStats)
            logger.log("📊 SDStats: Created new stats record for \(userId)")
        }
        
        try modelContext.save()
    }

    public func incrementTotalXP(userId: String, by amount: Int) async throws {
        // Fetch current streak to maintain it during the update
        let currentStreak = try await fetchStats(userId: userId)?.currentStreak ?? 0
        try await updateStats(userId: userId, xpDelta: amount, newStreak: currentStreak)
    }
}

extension SDUserStatsRepository: UserStatsSyncable {
    @MainActor
    public func overwriteStats(userId: String, totalXP: Int, newStreak: Int, lastUpdated: Date) async throws {
        let descriptor = FetchDescriptor<SDUserStats>(
            predicate: #Predicate<SDUserStats> { $0.userId == userId }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            existing.totalXP = totalXP
            existing.currentStreak = newStreak
            existing.lastUpdated = lastUpdated
            logger.log("🔄 SDStats: Overwritten with absolute values (Sync).")
        } else {
            let newStats = SDUserStats(
                userId: userId,
                currentStreak: newStreak,
                totalXP: totalXP,
                lastUpdated: lastUpdated
            )
            modelContext.insert(newStats)
        }
        
        try modelContext.save()
    }
}
