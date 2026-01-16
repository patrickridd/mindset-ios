//
//  SDPromptResponse.swift
//  Data
//
//  Created by patrick ridd on 1/12/26.
//

import Foundation
import SwiftData
import Domain

@Model
public final class SDPromptResponse {
    @Attribute(.unique) public var id: UUID
    public var promptId: String
    public var categoryValue: String // Store Enum as String
    public var userText: String
    public var aiReflection: String?
    
    // Relationship back to the parent
    public var entry: SDMindsetEntry?

    public init(
        id: UUID = UUID(),
        promptId: String,
        categoryValue: String,
        userText: String,
        aiReflection: String? = nil
    ) {
        self.id = id
        self.promptId = promptId
        self.categoryValue = categoryValue
        self.userText = userText
        self.aiReflection = aiReflection
    }
    
    public func toDomain() -> PromptResponse {
        PromptResponse(
            id: id,
            promptId: promptId,
            category: PromptCategory(rawValue: categoryValue) ?? .gratitude,
            userText: userText,
            aiReflection: aiReflection
        )
    }
    
    public static func fromDomain(_ domain: PromptResponse, with entry: SDMindsetEntry) -> SDPromptResponse {
        let response = SDPromptResponse(
            id: domain.id,
            promptId: domain.promptId,
            categoryValue: domain.category.rawValue,
            userText: domain.userText,
            aiReflection: domain.aiReflection
        )
        response.entry = entry
        return response
    }
}
