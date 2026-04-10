//
//  MockUserStatsRepository.swift
//  Domain
//
//  Created by patrick ridd on 4/8/26.
//


import Foundation

/// A thread-safe mock for simulating user progression and gamification stats.
public final class MockUserStatsRepository: UserStatsRepository, @unchecked Sendable {
    private let store = MockUserStatsStore()

    public init() {}

    public func incrementTotalXP(userId: String, by amount: Int) async throws {
        await store.incrementXP(userId: userId, by: amount)
        let currentXP = await store.fetchStats(userId: userId).totalXP
    }

    public func updateStats(userId: String, xpDelta: Int, newStreak: Int) async throws {
        try await store.updateStats(userId: userId, xpDelta: xpDelta, newStreak: newStreak)
    }

    public func fetchStats(userId: String) async throws -> UserStats? {
        return await store.fetchStats(userId: userId)
    }
}

extension MockUserStatsRepository: UserStatsSyncable {
    public func overwriteStats(userId: String, totalXP: Int, newStreak: Int, lastUpdated: Date) async throws {
        try await store.overwriteStats(userId: userId, totalXP: totalXP, newStreak: newStreak, lastUpdated: lastUpdated)
    }
}

actor MockUserStatsStore {
    private var mockStats: [String: UserStats] = [:]
    private var mockXP: [String: Int] = [:]
    private var mockStreaks: [String: Int] = [:]
    private var mockLastUpdated: [String: Date] = [:]
    
    func incrementXP(userId: String, by amount: Int) {
        let current = mockStats[userId]?.totalXP ?? 0
        mockStats[userId]?.totalXP = current + amount
    }
    
    public func updateStats(userId: String, xpDelta: Int, newStreak: Int) async throws {
        let current = mockXP[userId] ?? 0
        mockStats[userId] = UserStats(currentStreak: newStreak, totalXP: current + xpDelta, lastUpdated: Date())
    }
    
    func fetchStats(userId: String) -> UserStats {
        mockStats[userId] ?? UserStats()
    }

    public func overwriteStats(userId: String, totalXP: Int, newStreak: Int, lastUpdated: Date) async throws {
        mockStats[userId] = UserStats(currentStreak: newStreak, totalXP: totalXP, lastUpdated: lastUpdated)
    }
}

