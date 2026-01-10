//
//  SDMindsetEntry.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import Foundation
import SwiftData
import Domain

@Model
public final class SDMindsetEntry {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var gratitudeText: String
    public var goalText: String
    public var affirmationText: String
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

    public init (_ entry: MindsetEntry) {
        self.id = entry.id
        self.date = entry.date
        self.gratitudeText = entry.gratitudeText
        self.goalText = entry.goalText
        self.affirmationText = entry.affirmationText
        self.archetypeTag = entry.archetypeTag
        self.sentimentScore = entry.sentimentScore
    }

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
