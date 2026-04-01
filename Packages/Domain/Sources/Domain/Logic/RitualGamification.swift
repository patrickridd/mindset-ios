//
//  RitualGamification.swift
//  Domain
//
//  XP and archetype helpers for multi-slot rituals: count each logical prompt once.
//

public enum RitualGamification {
    /// Sums category XP once per logical prompt (uses `Prompt.basePromptId` on each response id).
    public static func earnedXP(from responses: [PromptResponse]) -> Int {
        var seenBaseIds = Set<PromptID>()
        var total = 0
        for response in responses {
            guard let base = Prompt.basePromptID(fromComposite: response.promptId) else { continue }
            guard !seenBaseIds.contains(base) else { continue }
            seenBaseIds.insert(base)
            total += response.category.xpValue
        }
        return total
    }

    /// Picks the display category that appeared most often as distinct logical prompts (one vote per base id).
    public static func primaryCategory(from responses: [PromptResponse]) -> PromptCategory? {
        var baseToCategory: [PromptID: PromptCategory] = [:]
        for response in responses {
            guard let base = Prompt.basePromptID(fromComposite: response.promptId) else { continue }
            baseToCategory[base] = response.category
        }
        let categoryCounts = Dictionary(
            grouping: baseToCategory.values,
            by: { $0 }
        ).mapValues { $0.count }
        return categoryCounts.max(by: { $0.value < $1.value })?.key
    }
}
