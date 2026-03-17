//
//  SDMindsetEntry.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import Domain
import Foundation
import SwiftData

@Model
public final class SDMindsetEntry {
    @Attribute(.unique) public var id: UUID
    public var userId: String // 👈 Added for cloud association
    public var date: Date
    public var archetypeTag: String?
    public var sentimentScore: Double?

    @Relationship(deleteRule: .cascade)
    public var responses: [SDPromptResponse] = []

    public init(
        id: UUID = UUID(),
        userId: String,
        date: Date = Date(),
        archetypeTag: String? = nil,
        sentimentScore: Double? = nil
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.archetypeTag = archetypeTag
        self.sentimentScore = sentimentScore
    }
    
    // Update mapping logic to include userId
    public func toDomain() -> MindsetEntry {
        MindsetEntry(
            id: id,
            userId: userId,
            date: date,
            responses: responses.map { $0.toDomain() },
            archetypeTag: archetypeTag,
            sentimentScore: sentimentScore
        )
    }

    public static func fromDomain(_ domainEntry: MindsetEntry) -> SDMindsetEntry {
        let sdEntry = SDMindsetEntry(
            id: domainEntry.id,
            userId: domainEntry.userId,
            date: domainEntry.date,
            archetypeTag: domainEntry.archetypeTag,
            sentimentScore: domainEntry.sentimentScore
        )
        let sdResponses = domainEntry.responses.map { response in
            let newResponse = SDPromptResponse(
                promptId: response.promptId,
                categoryValue: response.category.rawValue,
                userText: response.userText,
                aiReflection: response.aiReflection
            )
            newResponse.entry = sdEntry  // Set the inverse relationship
            return newResponse
        }
        sdEntry.responses = sdResponses
        return sdEntry
    }
}
