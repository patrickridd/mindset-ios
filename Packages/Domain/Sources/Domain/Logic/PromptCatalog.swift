//
//  PromptCatalog.swift
//  Domain
//

public enum PromptCatalog {
    
    public static let allPrompts: [MindsetPrompt] = MindsetPrompt.allCases

    // MARK: - Template Prompts

    public static let morningStartTemplateDefinitions: [MindsetPrompt] =
        MindsetPrompt.allCases.filter(\.isMorningTemplate)

    // MARK: - Retrieval

    public static func prompts(for category: PromptCategory) -> [MindsetPrompt] {
        allPrompts.filter { $0.category == category }
    }
}
