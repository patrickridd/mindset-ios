//
//  PromptPresentationResolver.swift
//  FeatureMindset
//

import Domain

struct PromptPresentationResolver {
    func presentationKind(for prompt: Prompt) -> PromptPresentationKind {
        if prompt.id == "template_todos" {
            return .todayGoals
        }
        return presentationKind(for: prompt.category)
    }

    func presentationKind(for category: PromptCategory) -> PromptPresentationKind {
        switch category {
        case .bestPossibleSelf, .mementoMori:
            .guidedVisualization
        case .gratitude, .credit, .savoring, .kindness, .futureSelf, .signatureStrength, .stoic:
            .defaultTextEntry
        }
    }
}
