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
    public let streakCount: Int
    public let totalXP: Int
    public let lastRitualDate: Date?
    public let badges: [String]
    public let archetype: String?

    /// Maps Domain ``UserStats`` to a DTO for Firebase storage.
    public init(from domain: UserStats) {
        self.streakCount = domain.streakCount
        self.totalXP = domain.totalXP
        self.lastRitualDate = domain.lastRitualDate
        self.badges = domain.badges
        self.archetype = domain.archetype
    }

    /// Converts the DTO back into the Domain ``UserStats``.
    public func toDomain() -> UserStats {
        UserStats(
            streakCount: streakCount,
            totalXP: totalXP,
            lastRitualDate: lastRitualDate,
            badges: badges,
            archetype: archetype
        )
    }
}
