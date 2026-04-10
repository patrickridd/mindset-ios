//
//  UserStatsDTO.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//
import Domain
import Foundation

/// A Codable representation of user metrics, including streaks and unlocked achievements.
public struct UserStatsDTO: Codable {
    public let currentStreak: Int
    public let totalXP: Int
    public let lastUpdated: Date?
    public let badges: [String]
    public let archetype: String?

    /// Maps Domain ``UserStats`` to a DTO for Firebase storage.
    public init(from domain: UserStats) {
        self.currentStreak = domain.currentStreak
        self.totalXP = domain.totalXP
        self.lastUpdated = domain.lastUpdated
        self.badges = domain.badges
        self.archetype = domain.archetype
    }

    /// Converts the DTO back into the Domain ``UserStats``.
    public func toDomain() -> UserStats {
        UserStats(
            currentStreak: currentStreak,
            totalXP: totalXP,
            lastUpdated: lastUpdated,
            badges: badges,
            archetype: archetype
        )
    }
}
