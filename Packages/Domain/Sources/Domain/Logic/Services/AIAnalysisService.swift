//
//  AIAnalysisService.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public protocol AIAnalysisService: Sendable {
    func generateFeedback(for prompt: Prompt, answer: String, aiTone: OnboardingData.AICoachTone) async throws -> String
}
