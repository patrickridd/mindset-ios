//
//  SDPromptResponse.swift
//  Data
//
//  Created by patrick ridd on 1/12/26.
//

import Domain
import Foundation
import SwiftData

@Model
public final class SDPromptResponse {
    @Attribute(.unique) public var id: UUID
    public var promptId: String
    public var categoryValue: String  // Store Enum as String
    public var answers: [String]
    public var aiReflection: String?

    // Relationship back to the parent
    public var entry: SDEntry?

    public init(
        id: UUID = UUID(),
        promptId: String,
        categoryValue: String,
        answers: [String],
        aiReflection: String? = nil
    ) {
        self.id = id
        self.promptId = promptId
        self.categoryValue = categoryValue
        self.answers = answers
        self.aiReflection = aiReflection
    }

    public func toDomain() -> PromptResponse {
        PromptResponse(
            id: id,
            promptId: promptId,
            category: PromptCategory(rawValue: categoryValue) ?? .gratitude,
            answers: answers,
            aiReflection: aiReflection
        )
    }

    public static func fromDomain(_ domain: PromptResponse, with entry: SDEntry)
        -> SDPromptResponse
    {
        let response = SDPromptResponse(
            id: domain.id,
            promptId: domain.promptId,
            categoryValue: domain.category.rawValue,
            answers: domain.answers,
            aiReflection: domain.aiReflection
        )
        response.entry = entry
        return response
    }
}
