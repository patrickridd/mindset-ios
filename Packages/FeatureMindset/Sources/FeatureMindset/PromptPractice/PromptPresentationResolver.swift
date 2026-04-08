//
//  PromptPresentationResolver.swift
//  FeatureMindset
//

import Domain

struct PromptPresentationResolver {
    func presentationKind(for prompt: Prompt) -> PromptPresentationKind {
        if prompt.id == MindsetPrompt.todoToday.id {
            return .todayGoals
        }

        return presentationKind(for: prompt.category)
    }

    func presentationKind(for category: PromptCategory) -> PromptPresentationKind {
        switch category {
        case .bestPossibleSelf, .mementoMori:
                .guidedVisualization
        case .credit, .savoring, .kindness, .futureSelf, .signatureStrength, .stoic, .gratitude:
                .defaultTextEntry
        }
    }

}
