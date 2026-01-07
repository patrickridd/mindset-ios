//
//  MindsetEntryDB.swift
//  Data
//
//  Created by patrick ridd on 1/6/26.
//


// Data/Sources/Data/Models/MindsetEntryDB.swift
import Foundation
import SwiftData
import Domain

@Model
public final class MindsetEntryDB {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    
    // The Ritual Triple
    public var gratitudeText: String
    public var goalText: String
    public var affirmationText: String
    
    // Future-proofing for AI Archetypes
    public var archetypeTag: String?
    public var sentimentScore: Double?

    public init(id: UUID, date: Date, gratitudeText: String, goalText: String, affirmationText: String, archetypeTag: String? = nil, sentimentScore: Double? = nil) {
        self.id = id
        self.date = date
        self.gratitudeText = gratitudeText
        self.goalText = goalText
        self.affirmationText = affirmationText
        self.archetypeTag = archetypeTag
        self.sentimentScore = sentimentScore
    }
    
    // Mapping back to Domain Entity
    public func toDomain() -> MindsetEntry {
        return MindsetEntry(
            id: id,
            date: date,
            gratitudeText: gratitudeText,
            goalText: goalText,
            affirmationText: affirmationText,
            archetypeTag: archetypeTag,
            sentimentScore: sentimentScore
        )
    }
}