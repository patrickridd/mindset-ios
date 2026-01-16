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
        let sdEntry = SDMindsetEntry(
            id: mindsetEntry.id,
            date: mindsetEntry.date,
            responses: [],
            archetypeTag: mindsetEntry.archetypeTag,
            sentimentScore: mindsetEntry.sentimentScore
        )
        
        let sdResponses = mindsetEntry.responses.map { response in
            let newResponse = SDPromptResponse(
                promptId: response.promptId,
                categoryValue: response.category.rawValue,
                userText: response.userText,
                aiReflection: response.aiReflection
            )
            newResponse.entry = sdEntry // Set the inverse relationship
            return newResponse
        }
        sdEntry.responses = sdResponses
        return sdEntry
    }
}
