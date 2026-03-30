//
//  GeminiAIService.swift
//  Data
//
//  Created by patrick ridd on 1/18/26.
//

import Domain
import Foundation
@preconcurrency import GoogleGenerativeAI

public final class GeminiAIService: AIAnalysisService, @unchecked Sendable {
    private let model: GenerativeModel
    private let logger: AppLogger

    public init(apiKey: String, logger: AppLogger) {
        self.model = GenerativeModel(name: "gemini-2.0-flash", apiKey: apiKey)
        self.logger = logger
    }

    public func generateFeedback(for prompt: Prompt, answer: String) async throws -> String {
        logger.log("🤖 Sending history to Gemini 2.0 Flash...")
        // We provide a "System Instruction" to keep Gemini in 'Coach Mode'
        let systemPrompt = """
            You are a high-performance mindset coach. 
            The user is performing a \(prompt.category) exercise.
            The question asked was: "\(prompt.questionText)"
            The user answered: "\(answer)"

            Provide a 1-sentence, encouraging, and insightful reflection. 
            Focus on psychological growth. Do not use emojis.
            """

        let response = try await model.generateContent(systemPrompt)

        logger.log("✅ Received: \(response.text ?? "Empty")")

        guard let text = response.text else {
            throw NSError(
                domain: "GeminiError", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No response text"])
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
