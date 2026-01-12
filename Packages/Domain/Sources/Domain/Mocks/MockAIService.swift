//
//  MockAIService.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public final class MockAIService: AIAnalysisService {
    public init() {}
    
    public func generateFeedback(for prompt: MindsetPrompt, answer: String) async throws -> String {
        try? await Task.sleep(for: .seconds(1.5)) // Simulate AI "thinking"
        
        // Simple heuristic-based mock feedback
        if answer.count < 10 {
            return "I hear you. Even small reflections like this help build the habit."
        }
        
        switch prompt.category {
        case .gratitude:
            return "It’s wonderful that you noticed that. Science shows that acknowledging these moments strengthens your resilience for the rest of the day."
        case .mementoMori:
            return "That's a powerful perspective. Focusing on what truly matters is the first step toward a more intentional life."
        default:
            return "Thank you for sharing that. It sounds like you're really leaning into the identity of a \(prompt.category.displayName)."
        }
    }
}
