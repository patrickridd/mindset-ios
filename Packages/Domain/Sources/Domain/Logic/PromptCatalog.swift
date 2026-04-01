//
//  PromptCatalog.swift
//  Domain
//

public enum PromptCatalog {
    
    public static let allPrompts: [PromptDefinition] = PromptDefinition.allCases

    // MARK: - Template Prompts

    public static let morningStartTemplateDefinitions: [PromptDefinition] =
        allPrompts.filter(\.isMorningTemplate)

    // MARK: - Retrieval

    public static func morningStartTemplate() -> [Prompt] {
        morningStartTemplateDefinitions.map(\.prompt)
    }

    public static func prompts(for category: PromptCategory) -> [Prompt] {
        allPrompts.filter { $0.category == category }.map(\.prompt)
    }

    public static func prompt(by id: PromptID) -> Prompt? {
        allPrompts.first { $0.id == id }?.prompt
    }
}
