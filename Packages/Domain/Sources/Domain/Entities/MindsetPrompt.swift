//
//  MindsetPrompt.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public struct MindsetPrompt: Identifiable, Sendable {
    public let id: String
    public let category: PromptCategory
    public let headline: String /// e.g., "The Kindness Booster"
    public let questionText: String   /// e.g., "What act of kindness did you perform today?"
    public let coachTip: String /// e.g., "Research suggests doing 5 small acts in one day for the biggest boost."
    public let scientificRationale: String /// e.g., "Targets the Pro-social happiness pathway."
}
