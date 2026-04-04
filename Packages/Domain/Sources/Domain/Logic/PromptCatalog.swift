//
//  PromptCatalog.swift
//  Domain
//

public enum PromptCatalog {
    
    public static let allPrompts: [PromptType] = PromptType.allCases

    // MARK: - Template Prompts

    public static let morningStartTemplateDefinitions: [PromptType] =
        PromptType.allCases.filter(\.isMorningTemplate)

    // MARK: - Retrieval

    public static func prompts(for category: PromptCategory) -> [PromptType] {
        allPrompts.filter { $0.category == category }
    }
}
