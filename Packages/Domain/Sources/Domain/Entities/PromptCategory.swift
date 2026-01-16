//
//  PromptCategory.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//


public enum PromptCategory: String, Codable, CaseIterable, Sendable {
    // Retrospective (Looking Back)
    case gratitude
    case credit
    
    // Present-Tense (Current Experience)
    case savoring
    case kindness
    
    // Prospective (Looking Forward)
    case bestPossibleSelf
    case futureSelf
    
    // Existential/Deep (Foundational)
    case signatureStrength
    case mementoMori
    case stoic
    
    /// The user-facing name for the "Skill Tree"
    public var displayName: String {
        switch self {
        case .gratitude:        return "Gratitude"
        case .credit:           return "Self-Credit"
        case .savoring:         return "Present Savoring"
        case .kindness:         return "Acts of Kindness"
        case .bestPossibleSelf: return "Best Possible Self"
        case .futureSelf:       return "Future Identity"
        case .signatureStrength: return "Core Strengths"
        case .mementoMori:      return "Perspective"
        case .stoic:            return "Mental Resilience"
        }
    }

    /// Gamification: Harder psychological tasks reward more XP
    public var xpValue: Int {
        switch self {
        case .gratitude, .credit:
            return 10
        case .savoring, .kindness, .futureSelf:
            return 15
        case .signatureStrength, .stoic:
            return 20
        case .bestPossibleSelf, .mementoMori:
            return 25 // These require deep visualization/writing
        }
    }

    /// Returns true if the category represents a forward-looking goal or intention
    public var isGoalOriented: Bool {
        self == .futureSelf || self == .bestPossibleSelf
    }
}
