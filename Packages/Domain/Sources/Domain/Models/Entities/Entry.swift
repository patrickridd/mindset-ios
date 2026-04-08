//
//  Entry.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

import Foundation

/// A core domain entity representing a single session of user reflection and AI interaction.
///
/// `Entry` serves as the primary container for a user's daily mindset ritual.
/// It aggregates multiple ``PromptResponse`` objects and stores high-level metadata
/// derived from AI analysis, such as the user's current archetype and emotional sentiment.
///
/// This entity is ``Sendable`` and immutable by default, ensuring thread-safety
/// across your synchronization and analysis pipelines.
public struct Entry: Identifiable, Sendable {
    
    /// The unique identifier for this specific session.
    public let id: UUID
    
    /// The unique identifier of the user who authored this entry.
    /// Used to maintain data ownership and security in cloud storage.
    public let userId: String
    
    /// The timestamp indicating when the reflection session was initiated.
    public let dateCreated: Date
    
    /// The timestamp indicating when the reflection session was last updated.
    public var lastUpdatedAt: Date
    
    /// The ordered collection of individual prompt-response pairs that make up the session.
    public let promptResponses: [PromptResponse]
    
    /// A classification tag determined by AI (e.g., "The Stoic Seeker") based on the entry's content.
    public var archetypeTag: String?
    
    /// A numerical value (typically -1.0 to 1.0) representing the emotional tone of the entry.
    public var sentimentScore: Double?

    /// Sum of XP Points earned for each PromptResponse in the `Entry` completed
    public let totalXpEarned: Int

    /// Initializes a new Entry.
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new `UUID`.
    ///   - userId: The author's unique identifier.
    ///   - date: The creation date. Defaults to `Date()`.
    ///   - promptResponses: The list of completed ``PromptResponse`` objects.
    ///   - archetypeTag: An optional AI-generated archetype identifier.
    ///   - sentimentScore: An optional score representing detected sentiment.
    ///   - totalXpEarned: Total XP Points earned for each PromptResponse in the `Entry` completed
    public init(
        id: UUID = UUID(),
        userId: String,
        dateCreated: Date = Date(),
        lastUpdatedAt: Date = Date(),
        promptResponses: [PromptResponse],
        archetypeTag: String? = nil,
        sentimentScore: Double? = nil,
        totalXpEarned: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.dateCreated = dateCreated
        self.lastUpdatedAt = lastUpdatedAt
        self.promptResponses = promptResponses
        self.archetypeTag = archetypeTag
        self.sentimentScore = sentimentScore
        self.totalXpEarned = totalXpEarned
    }

    init(entry: Entry, totalXpEarned: Int) {
        self.init(
            id: entry.id,
            userId: entry.userId,
            dateCreated: entry.dateCreated,
            lastUpdatedAt: entry.lastUpdatedAt,
            promptResponses: entry.promptResponses,
            archetypeTag: entry.archetypeTag,
            sentimentScore: entry.sentimentScore,
            totalXpEarned: totalXpEarned
        )
    }
}

