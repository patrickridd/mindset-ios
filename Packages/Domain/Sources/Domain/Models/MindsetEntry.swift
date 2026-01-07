//
//  MindsetEntry.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

import Foundation

public struct MindsetEntry: Codable, Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    
    // The "Morning Ritual" Triple
    public let gratitudeText: String
    public let goalText: String
    public let affirmationText: String
    
    // Future-proofing for "Identity Archetypes"
    public var archetypeTag: String? 
    public var sentimentScore: Double? // For AI-driven insights
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        gratitudeText: String,
        goalText: String,
        affirmationText: String,
        archetypeTag: String? = nil,
        sentimentScore: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.gratitudeText = gratitudeText
        self.goalText = goalText
        self.affirmationText = affirmationText
        self.archetypeTag = archetypeTag
        self.sentimentScore = sentimentScore
    }
}
