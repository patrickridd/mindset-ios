//
//  RitualSession.swift
//  Domain
//
//  Created by patrick ridd on 4/13/26.
//

public struct RitualSession: Sendable {
    public let title: String
    public let type: PromptType
    public let prompts: [Prompt]
}
