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
    
    /// The identifier of the ``Prompt`` to which it is in response to.
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

extension PromptResponse {
    /// Minimum Character count required for each PromptResponse answer in our `answers` array.
    public var minCharacterCount: Int { 3 }
    
    /// Business Rule: A response is valid if it has the correct number of answers and each answer meets the minimum character threshold.
    public var isValid: Bool {
        // 1. We try to find the Prompt.
        // Today this is only MindsetPrompt, but tomorrow this could be
        // a 'PromptProvider' that looks in the database for UserPrompts too.
        let prompt = findPrompt(for: self.promptId)
        
        // 2. If we have a Prompt, we must match its slot count
        if let prompt {
            guard answers.count == prompt.slots.count else { return false }
        } else {
            // If no Prompt is found (fallback), we just need at least one answer
            guard !answers.isEmpty else { return false }
        }
        
        // 3. Quality Check
        return answers.allSatisfy { answer in
            answer.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
        }
    }

    /// Helper abstracts "Where" the prompt comes from
    private func findPrompt(for id: String) -> (any Prompt)? {
        // Currently, we only have our built-in MindsetPrompts
        return MindsetPrompt(rawValue: id)
        // LATER: return MindsetPrompt(rawValue: id) ?? UserPromptRepository.find(id)
    }
}
