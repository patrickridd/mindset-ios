//
//  GeminiAIService.swift
//  Data
//
//  Created by patrick ridd on 1/18/26.
//


import GoogleGenerativeAI
import Domain
import Foundation

public final class GeminiAIService: AIAnalysisService, @unchecked Sendable {
    private let model: GenerativeModel

    public init(apiKey: String) {
        // 'flash' is optimized for speed and efficiency in chat/reflection apps
        self.model = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey)
    }

    public func generateFeedback(for prompt: MindsetPrompt, answer: String) async throws -> String {
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
        
        guard let text = response.text else {
            throw NSError(domain: "GeminiError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response text"])
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
