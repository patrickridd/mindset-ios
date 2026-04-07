//
//  PromptCatalog.swift
//  Domain
//

public enum PromptCatalog {
    
    public static let allPrompts: [PromptLibrary] = PromptLibrary.allCases

    // MARK: - Template Prompts

    public static let morningStartTemplateDefinitions: [PromptLibrary] =
        PromptLibrary.allCases.filter(\.isMorningTemplate)

    // MARK: - Retrieval

    public static func prompts(for category: PromptCategory) -> [PromptLibrary] {
        allPrompts.filter { $0.category == category }
    }
}
