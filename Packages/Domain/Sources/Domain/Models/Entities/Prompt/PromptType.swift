//
//  PromptType.swift
//  Domain
//
//  Created by patrick ridd on 4/6/26.
//

public enum PromptType: String, Sendable, Codable {
    case morning   // Focus: Intentions, Goals, Optimism
    case evening   // Focus: Reflection, Savoring, Grounding
    case anytime   // Focus: Quick wins, Stress relief
    case deepWork  // Focus: Monthly goals, Letters, Deep Dive
    
    public var iconName: String {
        switch self {
        case .morning: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        case .anytime: return "sparkles"
        case .deepWork: return "book.closed.fill"
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .morning: return .orange
        case .evening: return .indigo
        case .anytime: return .mint
        case .deepWork: return .purple
        }
    }
}
