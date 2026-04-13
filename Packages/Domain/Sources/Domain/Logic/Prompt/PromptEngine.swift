//
//  PromptEngine.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public struct PromptEngine {
    public init() {}

    /// Fetches the default morning ritual template (`PromptLibrary.morningStartTemplate`).
    /// - Parameters:
    ///   - profile: Reserved for future personalization; currently unused.
    ///   - completedCount: Reserved for future rotation across template variants.
    public func fetchPrompts(for profile: User?, completedCount: Int) -> [Prompt] {
        guard profile?.onboardingData.mindsetGoal != nil else {
            return PromptCatalog.morningStartTemplateDefinitions
        }

        var selectedPrompts: [Prompt] = []

        // 1. Resolve categories based on profile (if it exists)
        let categories: [PromptCategory]
        if let profile = profile {
            categories = resolveCategories(for: profile)
        } else {
            // Default categories for new/missing users
            categories = [.gratitude, .bestPossibleSelf, .stoic, .futureSelf]
        }

        // 2. Select prompts from the Library
        for category in categories {
            let categoryPrompts = PromptCatalog.prompts(for: category)
            if !categoryPrompts.isEmpty {
                // Use rotation logic: (completedCount % count)
                let index = completedCount % categoryPrompts.count
                selectedPrompts.append(categoryPrompts[index])
            }

            if selectedPrompts.count >= 3 { break }
        }

        // 3. THE SAFETY NET: If the library is empty or logic failed,
        // return hardcoded "Emergency" prompts.
        if selectedPrompts.isEmpty {
            return PromptCatalog.morningStartTemplateDefinitions
        }
        return selectedPrompts
    }

    private func resolveCategories(for profile: User) -> [PromptCategory] {
        // Prefer new headspace (MLP quiz Q1); fall back to legacy overwhelmedFrequency
        guard profile.onboardingData.mindsetGoal != nil else {
            return PromptCatalog.morningStartTemplateDefinitions.map { $0.category }
        }

        let isOverwhelmed: Bool
        isOverwhelmed = (profile.onboardingData.headspace == .overwhelmed || profile.onboardingData.headspace == .restless)

        if isOverwhelmed {
            return [.savoring, .gratitude, .stoic, .futureSelf]
        } else {
            return [.bestPossibleSelf, .kindness, .signatureStrength]
        }
    }
}
