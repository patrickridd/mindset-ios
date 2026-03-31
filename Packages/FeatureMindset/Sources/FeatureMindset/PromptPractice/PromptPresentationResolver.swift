//
//  PromptPresentationResolver.swift
//  FeatureMindset
//

import Domain

struct PromptPresentationResolver {
    func presentationKind(for prompt: Prompt) -> PromptPresentationKind {
        presentationKind(for: prompt.category)
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
