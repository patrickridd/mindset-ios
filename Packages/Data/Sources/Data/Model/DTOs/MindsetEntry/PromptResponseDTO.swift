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
    public let userText: String
    public let aiReflection: String?

    public init(from domain: PromptResponse) {
        self.id = domain.id.uuidString
        self.promptId = domain.promptId
        self.category = domain.category.rawValue
        self.userText = domain.userText
        self.aiReflection = domain.aiReflection
    }

    public func toDomain() -> PromptResponse {
        PromptResponse(
            id: UUID(uuidString: id) ?? UUID(),
            promptId: promptId,
            category: PromptCategory(rawValue: category) ?? .gratitude, // Fallback to a default
            userText: userText,
            aiReflection: aiReflection
        )
    }
}
