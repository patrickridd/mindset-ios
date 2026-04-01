//
//  PromptLibrary.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public enum PromptLibrary {
    /// Backwards-compatible facade for legacy call sites.
    public static var morningStartTemplate: [Prompt] {
        PromptCatalog.morningStartTemplate()
    }

    /// Backwards-compatible facade for legacy call sites.
    public static var allPrompts: [Prompt] {
        PromptCatalog.allPrompts.map(\.prompt)
    }
}
