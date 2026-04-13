//
//  RitualGenerator.swift
//  Domain
//
//  Created by patrick ridd on 4/13/26.
//


public protocol RitualGenerator: Sendable {
    func generateSession(for type: PromptType, user: User, history: [Entry]) -> RitualSession
}
