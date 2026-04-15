//
//  OnboardingQuestion.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/30/26.
//

import Domain
import Foundation

/// A single onboarding quiz question with options and mapping to Domain ``User`` fields.
public struct OnboardingQuestion: Sendable {
    public let id: Int
    public let questionText: String
    public let options: [String]
    /// Maps option index to the value stored in Domain ``User``
    public let logic: Logic

    public enum Logic: Sendable {
        case headspace         // Current Symptom
        case targetEmotion      // Specific Pain Point (New)
        case responseToSetback // CBT/Stoic Diagnostic
        case planningStyle     // Utility/Habit Mapping (New)
        case aiCoachTone       // UX Preference
    }

    public init(id: Int, questionText: String, options: [String], logic: Logic) {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.logic = logic
    }
}

// MARK: - Quiz Definition (MLP Spec)

extension OnboardingQuestion {
    public static let allQuestions: [OnboardingQuestion] = [
        // 1. SYMPTOM: How do you feel right now?
        OnboardingQuestion(
            id: 1,
            questionText: "How would you describe your current headspace?",
            options: ["Restless", "Focused", "Overwhelmed", "Content"],
            logic: .headspace
        ),
        // 2. PAIN POINT: What is the primary obstacle? (Feeds the Insight Engine)
        OnboardingQuestion(
            id: 2,
            questionText: "Which of these do you want to manage better?",
            options: ["Anxiety & Stress", "Lack of Focus", "Self-Doubt", "Anger/Frustration"],
            logic: .targetEmotion
        ),
        // 3. DIAGNOSTIC: How do you fail? (The CBT/Stoic "Intervention" check)
        OnboardingQuestion(
            id: 3,
            questionText: "When things go wrong, your first instinct is to...",
            options: ["Blame yourself", "Rush to fix it", "Shut down/Get stuck", "Blame others"],
            logic: .responseToSetback
        ),
        // 4. UTILITY: When do you want to build your intentions? (The Habit Hook)
        OnboardingQuestion(
            id: 4,
            questionText: "When is your best time for daily goal setting?",
            options: ["First thing in the morning", "Last thing before bed", "I'm not sure yet"],
            logic: .planningStyle
        ),
        // 5. UX: How do you want to be talked to?
        OnboardingQuestion(
            id: 5,
            questionText: "Pick a 'Guide' personality for your AI coach.",
            options: [
                "The Sage (Reflective)",
                "The Cheerleader (Warm)",
                "The Therapist (Insightful)",
                "The Friend (Casual)"
            ],
            logic: .aiCoachTone
        ),
    ]
}
