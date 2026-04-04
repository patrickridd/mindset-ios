//
//  PromptResponseDTO.swift
//  Data
//
//  Created by patrick ridd on 3/19/26.
//

import Domain
import Foundation

/// A Codable representation of a single Q&A pair within a ritual.
public struct PromptResponseDTO: Codable {
    public let id: String
    public let promptId: String
    public let category: String
    public let answers: [String]
    public let aiReflection: String?

    public init(from domain: PromptResponse) {
        self.id = domain.id.uuidString
        self.promptId = domain.promptId
        self.category = domain.category.rawValue
        self.answers = domain.answers
        self.aiReflection = domain.aiReflection
    }

    public func toDomain() -> PromptResponse {
        PromptResponse(
            id: UUID(uuidString: id) ?? UUID(),
            promptId: promptId,
            category: PromptCategory(rawValue: category) ?? .gratitude, // Fallback to a default
            answers: answers,
            aiReflection: aiReflection
        )
    }
}
