//
//  PromptEngine.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//


public struct PromptEngine {
    public init() {}
    public func fetchPrompts(for profile: UserProfile, completedCount: Int) -> [MindsetPrompt] {
        var selectedPrompts: [MindsetPrompt] = []
        
        // 1. Resolve which categories fit this user
        let categories = resolveCategories(for: profile)
        
        // 2. Select one prompt from each prioritized category
        for category in categories {
            if let categoryPrompts = PromptLibrary.allPrompts[category] {
                // For now, we pick the first one. 
                // Later, we can use (completedCount % categoryPrompts.count) to rotate them.
                if let prompt = categoryPrompts.first {
                    selectedPrompts.append(prompt)
                }
            }
            
            // Limit to 3 prompts per ritual to prevent burnout
            if selectedPrompts.count >= 3 { break }
        }
        
        return selectedPrompts
    }
    
    private func resolveCategories(for profile: UserProfile) -> [PromptCategory] {
        // High-level logic mapping profile to science
        if profile.overwhelmedFrequency == .often {
            return [.savoring, .gratitude, .stoic]
        } else {
            return [.bestPossibleSelf, .kindness, .signatureStrength]
        }
    }
}
