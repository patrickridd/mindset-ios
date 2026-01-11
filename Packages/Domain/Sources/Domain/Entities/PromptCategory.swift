//
//  PromptCategory.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//


public enum PromptCategory: String, Codable, CaseIterable, Sendable {
    // Retrospective (Looking Back)
    case gratitude        // Perspective on the past
    case credit           // Self-efficacy/Wins
    
    // Present-Tense (Current Experience)
    case savoring         // Mindfulness of current joy
    case kindness         // Pro-social action/Outward focus
    
    // Prospective (Looking Forward)
    case bestPossibleSelf // Optimism and goal alignment
    case futureSelf       // Long-term identity
    
    // Existential/Deep (Foundational)
    case signatureStrength // Using core character traits
    case mementoMori      // Urgency and priority
    case stoic            // Control and resilience
    
    public var xpValue: Int {
        switch self {
        case .gratitude: return 10
        case .mementoMori: return 25 // More "mental effort" = more XP
        default: return 15
        }
    }
}
