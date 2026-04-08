//
//  RitualGamification.swift
//  Domain
//
//  XP and archetype helpers for multi-slot rituals: count each logical prompt once.
//

public enum RitualGamification {
    /// Sums category XP once per logical prompt.
    public static func earnedXP(from responses: [PromptResponse]) -> Int {
        var seenBaseIds = Set<String>()
        var total = 0
        
        for response in responses {
            // Use the Mapper here instead of Prompt.basePromptID
            let base = PromptPersistenceMapper.parseBaseID(from: response.promptId)
            
            guard !seenBaseIds.contains(base) else { continue }
            
            seenBaseIds.insert(base)
            total += response.category.xpValue
        }
        return total
    }

    /// Picks the display category that appeared most often as distinct logical prompts.
    public static func primaryCategory(from responses: [PromptResponse]) -> PromptCategory? {
        var baseToCategory: [String: PromptCategory] = [:]
        
        for response in responses {
            let base = PromptPersistenceMapper.parseBaseID(from: response.promptId)
            baseToCategory[base] = response.category
        }
        
        // Count how many times each category appeared across unique base IDs
        let categoryCounts = Dictionary(grouping: baseToCategory.values, by: { $0 })
            .mapValues { $0.count }
            
        return categoryCounts.max(by: { $0.value < $1.value })?.key
    }
}

public enum PromptPersistenceMapper {
    private static let separator = "#"

    /// Extracts the base ID (e.g., "gratitude") from a composite string (e.g., "gratitude#1")
    public static func parseBaseID(from compositeId: String) -> String {
        guard let range = compositeId.range(of: separator) else {
            return compositeId
        }
        return String(compositeId[..<range.lowerBound])
    }
}
