//
//  PromptResponse.swift
//  Domain
//
//  Created by patrick ridd on 4/3/26.
//

import Foundation

/// A Domain model representing a user's answers to a specific prompt and the AI's subsequent feedback.
///
/// This structure captures the complete "interaction" for a single prompt, whether it has
/// one response slot or many (e.g., a 3-item gratitude list).
/// 
public struct PromptResponse: Identifiable, Sendable {
    
    public let id: UUID
    
    /// The stable identifier of the ``PromptType`` (e.g., "gratitude").
    public let promptId: String
    
    /// The category determines the thematic focus and XP weighting.
    public let category: PromptCategory
    
    /// The collection of answers provided by the user.
    /// For a single-slot prompt, this will have one element.
    public let answers: [String]
    
    /// The AI's holistic reflection based on all answers in this response.
    public let aiReflection: String?

    public init(
        id: UUID = UUID(),
        promptId: String,
        category: PromptCategory,
        answers: [String],
        aiReflection: String? = nil
    ) {
        self.id = id
        self.promptId = promptId
        self.category = category
        self.answers = answers
        self.aiReflection = aiReflection
    }
}
