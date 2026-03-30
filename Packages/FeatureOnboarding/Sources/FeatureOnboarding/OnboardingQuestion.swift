//
//  OnboardingQuestion.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/30/26.
//

import Domain
import Foundation

/// A single onboarding quiz question with options and mapping to UserProfile fields.
public struct OnboardingQuestion: Sendable {
    public let id: Int
    public let questionText: String
    public let options: [String]
    /// Maps option index to the value stored in UserProfile
    public let logic: Logic

    public enum Logic: Sendable {
        case headspace
        case mentalMuscle
        case responseToSetback
        case mindsetGoal
        case aiCoachTone
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

    /// All 5 onboarding questions per MLP spec.
    public static let allQuestions: [OnboardingQuestion] = [
        OnboardingQuestion(
            id: 1,
            questionText: "How would you describe your current headspace?",
            options: ["Restless", "Focused", "Overwhelmed", "Content"],
            logic: .headspace
        ),
        OnboardingQuestion(
            id: 2,
            questionText: "Which \"Mental Muscle\" do you want to build?",
            options: ["Resilience", "Gratitude", "Purpose", "Calm"],
            logic: .mentalMuscle
        ),
        OnboardingQuestion(
            id: 3,
            questionText: "When things go wrong, I usually...",
            options: ["Blame myself", "Fix it", "Get stuck", "Blame others"],
            logic: .responseToSetback
        ),
        OnboardingQuestion(
            id: 4,
            questionText: "What's your primary \"habit\" goal?",
            options: ["Consistency", "Deep Reflection", "Better Sleep"],
            logic: .mindsetGoal
        ),
        OnboardingQuestion(
            id: 5,
            questionText: "Pick a \"Guide\" tone for your AI coach.",
            options: [
                "The Sage (Reflective)",
                "The Cheerleader (Warm)",
                "The Therapist (Empathetic & Insightful)",
                "The Friend (Casual)",
            ],
            logic: .aiCoachTone
        ),
    ]
}
