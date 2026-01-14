//
//  MindsetEntry.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

import Foundation

public struct MindsetEntry: Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    
    // The individual prompt-response pairs (The children)
    public let responses: [PromptResponse]
    
    // Daily Metadata (What you wanted to keep)
    public var archetypeTag: String?
    public var sentimentScore: Double?
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        responses: [PromptResponse],
        archetypeTag: String? = nil,
        sentimentScore: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.responses = responses
        self.archetypeTag = archetypeTag
        self.sentimentScore = sentimentScore
    }
}

// The new "Child" object that holds the AI feedback
public struct PromptResponse: Identifiable, Sendable {
    public let id: UUID
    public let promptId: String
    public let category: PromptCategory
    public let userText: String
    public let aiReflection: String?
    
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
