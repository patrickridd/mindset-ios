//
//  UserStatsRepository.swift
//  Domain
//
//  Created by patrick ridd on 4/8/26.
//


/// Handles the high-frequency "Game" data of the user.
/// Separated from UserRepository to allow for independent scaling of stats vs. identity.
public protocol UserStatsRepository: Sendable {
    /// Fetches only the stats-related data for the dashboard.
    func fetchStats(userId: String) async throws -> UserStats?
    
    /// Atomically increments the user's total XP.
    func incrementTotalXP(userId: String, by amount: Int) async throws

    /// Updates User XP and NEW Streak Stats
    func updateStats(userId: String, xpDelta: Int, newStreak: Int) async throws
}
