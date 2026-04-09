//
//  RitualGamification.swift
//  Domain
//
//  XP and archetype helpers for multi-slot rituals: count each logical prompt once.
//

public enum RitualGamification: Sendable {
    
    /// Calculates total XP by looking up the actual MindsetPrompt definition
    public static func earnedXP(from responses: [PromptResponse]) -> Int {
        var total = 0
        
        for response in responses {
            // 1. Convert the ID string back to our Typed Enum
            guard let prompt = MindsetPrompt(rawValue: response.promptId) else {
                // If it's a user-generated prompt or unknown, use category default
                total += response.category.xpValue
                continue
            }
            
            // 2. Sum the weights of the slots that actually have answers
            // This rewards users more for multi-slot "Deep Dives"
            for (index, answer) in response.answers.enumerated() {
                guard !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
                
                // Get the weight from the template's slot metadata
                if index < prompt.slots.count {
                    total += prompt.slots[index].xpPoints
                }
            }
        }
        return total
    }

    public static func primaryCategory(from responses: [PromptResponse]) -> PromptCategory? {
        // Since we are no longer "clumping" by base IDs (because each prompt
        // in a ritual should be unique now), we can just count the categories.
        let categoryCounts = Dictionary(grouping: responses.map { $0.category }, by: { $0 })
            .mapValues { $0.count }

        return categoryCounts.max(by: { $0.value < $1.value })?.key
    }
}
