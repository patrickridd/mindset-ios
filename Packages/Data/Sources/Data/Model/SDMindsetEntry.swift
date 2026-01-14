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
    public var archetypeTag: String?
    public var sentimentScore: Double?
    
    // Relationship: One Entry has many Responses
    @Relationship(deleteRule: .cascade)
    public var responses: [SDPromptResponse] = []
    
    public init(id: UUID = UUID(), date: Date = Date(), responses: [SDPromptResponse] = [], archetypeTag: String? = nil, sentimentScore: Double? = nil) {
        self.id = id
        self.date = date
        self.archetypeTag = archetypeTag
        self.sentimentScore = sentimentScore
    }
    
    public func toDomain() -> MindsetEntry {
        MindsetEntry(
            id: id,
            date: date,
            responses: responses.map { $0.toDomain() },
            archetypeTag: archetypeTag,
            sentimentScore: sentimentScore
        )
    }

    public static func fromDomain(_ mindsetEntry: MindsetEntry) -> SDMindsetEntry {
        SDMindsetEntry(
            id: mindsetEntry.id,
            date: mindsetEntry.date,
            responses: mindsetEntry.responses.map { SDPromptResponse.fromDomain($0) },
            archetypeTag: mindsetEntry.archetypeTag,
            sentimentScore: mindsetEntry.sentimentScore
        )
    }
}
