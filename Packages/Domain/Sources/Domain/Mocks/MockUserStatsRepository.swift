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

actor MockUserStatsStore {
    private var mockXP: [String: Int] = [:]
    private var mockStreaks: [String: Int] = [:]

    func incrementXP(userId: String, by amount: Int) {
        let current = mockXP[userId] ?? 0
        mockXP[userId] = current + amount
    }
    
    public func updateStats(userId: String, xpDelta: Int, newStreak: Int) async throws {
        let current = mockXP[userId] ?? 0
        mockXP[userId] = current + xpDelta
        mockStreaks[userId] = newStreak
    }
    
    func fetchStats(userId: String) -> UserStats {
        let xp = mockXP[userId] ?? 0
        let streak = mockStreaks[userId] ?? 0
        return UserStats(currentStreak: streak, totalXP: xp)
    }
}

