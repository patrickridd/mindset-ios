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

    /// Initializes a new Entry.
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new `UUID`.
    ///   - userId: The author's unique identifier.
    ///   - date: The creation date. Defaults to `Date()`.
    ///   - promptResponses: The list of completed ``PromptResponse`` objects.
    ///   - archetypeTag: An optional AI-generated archetype identifier.
    ///   - sentimentScore: An optional score representing detected sentiment.
    public init(
        id: UUID = UUID(),
        userId: String,
        dateCreated: Date = Date(),
        lastUpdatedAt: Date = Date(),
        promptResponses: [PromptResponse],
        archetypeTag: String? = nil,
        sentimentScore: Double? = nil
    ) {
        self.id = id
        self.userId = userId
        self.dateCreated = dateCreated
        self.lastUpdatedAt = lastUpdatedAt
        self.promptResponses = promptResponses
        self.archetypeTag = archetypeTag
        self.sentimentScore = sentimentScore
    }
}

/// A value object representing a user's answer to a specific prompt and the AI's subsequent feedback.
///
/// This structure captures the granular "conversation" between the user and the AI coach.
/// Each response is associated with a specific ``PromptCategory`` to drive different
/// coaching tones and logic.
public struct PromptResponse: Identifiable, Sendable {
    
    /// The unique identifier for this specific response.
    public let id: UUID
    
    /// The identifier of the original prompt the user answered.
    public let promptId: String
    
    /// The category of the prompt, determining the thematic focus (e.g., Gratitude, Resilience).
    public let category: PromptCategory
    
    /// The raw text input provided by the user.
    public let userText: String
    
    /// The personalized feedback or perspective provided by the AI in response to the user's text.
    /// This may be `nil` if the entry has been saved but the AI analysis is still pending.
    public let aiReflection: String?

    /// Initializes a new PromptResponse.
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new `UUID`.
    ///   - promptId: The ID of the parent prompt.
    ///   - category: The thematic category of this response.
    ///   - userText: The user's typed response.
    ///   - aiReflection: The optional AI-generated coaching reflection.
    public init(
        id: UUID = UUID(),
        promptId: String,
        category: PromptCategory,
        userText: String,
        aiReflection: String? = nil
    ) {
        self.id = id
        self.promptId = promptId
        self.category = category
        self.userText = userText
        self.aiReflection = aiReflection
    }
}
