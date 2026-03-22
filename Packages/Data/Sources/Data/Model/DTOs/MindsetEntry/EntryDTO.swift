//
//  EntryDTO.swift
//  Data
//
//  Created by patrick ridd on 3/19/26.
//

import Domain
import Foundation

/// A Codable representation of a daily ritual session for Remote storage.
public struct EntryDTO: Codable {
    public let id: String
    public let userId: String
    public let dateCreated: Date
    public let lastUpdatedAt: Date
    public let promptResponses: [PromptResponseDTO]
    public let archetypeTag: String?
    public let sentimentScore: Double?

    public init(from domain: Entry) {
        self.id = domain.id.uuidString
        self.userId = domain.userId
        self.dateCreated = domain.dateCreated
        self.lastUpdatedAt = domain.lastUpdatedAt
        self.promptResponses = domain.promptResponses.map { PromptResponseDTO(from: $0) }
        self.archetypeTag = domain.archetypeTag
        self.sentimentScore = domain.sentimentScore
    }

    public func toDomain() -> Entry {
        Entry(
            id: UUID(uuidString: id) ?? UUID(),
            userId: userId,
            dateCreated: dateCreated,
            lastUpdatedAt: lastUpdatedAt,
            promptResponses: promptResponses.map { $0.toDomain() },
            archetypeTag: archetypeTag,
            sentimentScore: sentimentScore
        )
    }
}
