//
//  SDUserStats.swift
//  Data
//
//  Created by patrick ridd on 4/9/26.
//
import Domain
import Foundation
import SwiftData

@Model
public final class SDUserStats {
    @Attribute(.unique) public var userId: String
    
    // Flattened Stats Data
    public var currentStreak: Int
    public var totalXP: Int
    public var lastUpdated: Date?
    public var archetype: String?
    public var badges: [String]

    public init(
        userId: String,
        currentStreak: Int = 0,
        totalXP: Int = 0,
        lastUpdated: Date? = nil,
        archetype: String? = nil,
        badges: [String] = []
    ) {
        self.userId = userId
        self.currentStreak = currentStreak
        self.totalXP = totalXP
        self.lastUpdated = lastUpdated
        self.archetype = archetype
        self.badges = badges
    }

    // MARK: - Mapping

    /// Maps `SDUserStats` to our Domain's ``UserStats``
    public func toDomain() -> UserStats {
        return UserStats(
            currentStreak: currentStreak,
            totalXP: totalXP,
            lastUpdated: lastUpdated,
            badges: badges,
            archetype: archetype
        )
    }

    /// Use for creating (Inserting) a new stats record from a Domain model
    public static func fromDomain(userId: String, domain: UserStats) -> SDUserStats {
        return SDUserStats(
            userId: userId,
            currentStreak: domain.currentStreak,
            totalXP: domain.totalXP,
            lastUpdated: domain.lastUpdated,
            archetype: domain.archetype,
            badges: domain.badges
        )
    }
}

extension SDUserStats {
    /// UPDATES the current instance using values from a Domain struct
    /// Useful for the `updateStats` method in your Repository.
    func update(from domain: UserStats) {
        self.currentStreak = domain.currentStreak
        self.totalXP = domain.totalXP
        self.lastUpdated = domain.lastUpdated
        self.archetype = domain.archetype
        self.badges = domain.badges
    }
}
