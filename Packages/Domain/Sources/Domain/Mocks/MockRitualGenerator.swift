//
//  MockRitualGenerator.swift
//  Domain
//
//  Created by patrick ridd on 4/13/26.
//


public final class MockRitualGenerator: RitualGenerator, Sendable {
    public init() {}

    public func generateSession(for type: PromptType, user: User, history: [Entry]) -> RitualSession {
        // Return a fixed, predictable set of prompts for testing/previews
        let mockPrompts: [Prompt] = [
            MindsetPrompt.gratitude,
            MindsetPrompt.stoic,
            MindsetPrompt.futureSelf
        ]

        return RitualSession(
            title: "Mock \(type.rawValue.capitalized) Ritual",
            type: type,
            prompts: mockPrompts
        )
    }
}
