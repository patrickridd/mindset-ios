//
//  UserStats.swift
//  Domain
//
//  Created by patrick ridd on 3/16/26.
//

import Foundation

/// Dynamic gamification data
public struct UserStats: Sendable {
    public var currentStreak: Int = 0
    public var totalXP: Int = 0
    public var lastUpdated: Date?
    public var badges: [String] = [] // Use IDs like "first_reflection"
    public var archetype: String?    // Result of the AI analysis
    
    public init(currentStreak: Int = 0, totalXP: Int = 0, lastUpdated: Date? = nil, badges: [String] = [], archetype: String? = nil) {
        self.currentStreak = currentStreak
        self.totalXP = totalXP
        self.lastUpdated = lastUpdated
        self.badges = badges
        self.archetype = archetype
    }
}
