//
//  PromptEngine.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//


public struct PromptEngine {
    public init() {}
    
    /// Fetches prompts based on user profile with a guaranteed fallback to prevent blank screens.
    public func fetchPrompts(for profile: UserProfile?, completedCount: Int) -> [MindsetPrompt] {
        var selectedPrompts: [MindsetPrompt] = []
        
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
            if let categoryPrompts = PromptLibrary.allPrompts[category] {
                // Use rotation logic: (completedCount % count)
                let index = completedCount % categoryPrompts.count
                selectedPrompts.append(categoryPrompts[index])
            }
            
            if selectedPrompts.count >= 3 { break }
        }
        
        // 3. THE SAFETY NET: If the library is empty or logic failed,
        // return hardcoded "Emergency" prompts.
        if selectedPrompts.isEmpty {
            return fallbackPrompts
        }
        
        return selectedPrompts
    }
    
    private func resolveCategories(for profile: UserProfile) -> [PromptCategory] {
        if profile.overwhelmedFrequency == .often {
            return [.savoring, .gratitude, .stoic, .futureSelf]
        } else {
            return [.bestPossibleSelf, .kindness, .signatureStrength]
        }
    }
    
    // Hardcoded fallbacks ensure the app works even if the PromptLibrary data is corrupted.
    private var fallbackPrompts: [MindsetPrompt] {
        [
            MindsetPrompt(
                id: "fb_gratitude",
                category: .gratitude,
                headline: "Small Wins",
                questionText: "What is one thing that went well today?",
                coachTip: "Noticing small wins recalibrates your brain for positivity.",
                scientificRationale: "Daily Gratitude has shown to reduce stress and improve mental health."
            ),
            MindsetPrompt(
                id: "fb_future",
                category: .futureSelf,
                headline: "Intentionality",
                questionText: "What is your main focus for the next few hours?",
                coachTip: "Defining a focus reduces cognitive load and anxiety.",
                scientificRationale: "Being intentional has been proven to increase well-being and reduce stress."
            )
        ]
    }
}
