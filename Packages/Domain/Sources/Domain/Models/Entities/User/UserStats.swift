//
//  UserStats.swift
//  Domain
//
//  Created by patrick ridd on 3/16/26.
//

import Foundation

/// Dynamic gamification data
public struct UserStats: Sendable {
    public var streakCount: Int = 0
    public var totalXP: Int = 0
    public var lastRitualDate: Date?
    public var badges: [String] = [] // Use IDs like "first_reflection"
    public var archetype: String?    // Result of the AI analysis
    
    public init(streakCount: Int = 0, totalXP: Int = 0, lastRitualDate: Date? = nil, badges: [String] = [], archetype: String? = nil) {
        self.streakCount = streakCount
        self.totalXP = totalXP
        self.lastRitualDate = lastRitualDate
        self.badges = badges
        self.archetype = archetype
    }
}
