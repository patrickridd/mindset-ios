//
//  OnboardingViewModel.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/11/26.
//

import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class OnboardingViewModel {
    private let userRepository: UserRepository
    public var onboardingFinished: (() -> Void)?

    public var currentStep = 0
    public var isCalculating = false

    /// Option currently highlighted before advancing (cleared after transition).
    public var selectedOption: String?
    /// When true, question transition slides backward (insert from leading, remove to trailing).
    public var isGoingBack = false

    /// Captured answers (option strings), keyed by question logic
    private var answers: [OnboardingQuestion.Logic: String] = [:]

    /// Typewriter Animation State: tracks which questions have been animated
    public var animatedQuestionIds: Set<Int> = []

    public let questions = OnboardingQuestion.allQuestions

    public init(
        userRepository: UserRepository,
        onboardingFinished: (() -> Void)?
    ) {
        self.userRepository = userRepository
        self.onboardingFinished = onboardingFinished
    }

    public func selectOption(_ option: String) {
        let question = questions[currentStep]
        answers[question.logic] = option

        if currentStep < questions.count - 1 {
            currentStep += 1
        } else {
            startCalculation()
        }
    }

    /// Previously selected answer for the current step (e.g. when user went back). Nil if not yet answered.
    public var selectedAnswerForCurrentStep: String? {
        guard currentStep < questions.count else { return nil }
        return answers[questions[currentStep].logic]
    }

    /// True when the back button should be shown (not calculating and not on first step).
    public var isBackButtonDisplayed: Bool {
        !isCalculating && currentStep > 0
    }

    /// Progress for the step progress bar (0...1). First step shows a small nub (0.025); calculating shows full.
    public var progress: Double {
        if isCalculating { return 1.0 }
        if currentStep == 0 { return 0.025 }
        return Double(currentStep) / Double(questions.count)
    }

    /// Returns true if the current question should show typewriter animation (not yet animated).
    public var shouldAnimateCurrentQuestion: Bool {
        guard currentStep < questions.count else { return false }
        let questionId = questions[currentStep].id
        return !animatedQuestionIds.contains(questionId)
    }

    /// Marks the current question as animated (won't animate again if user goes back).
    public func markCurrentQuestionAnimated() {
        guard currentStep < questions.count else { return }
        let questionId = questions[currentStep].id
        animatedQuestionIds.insert(questionId)
    }

    /// Go back to the previous quiz step. No-op if already at step 0 or calculating.
    public func goBack() {
        guard !isCalculating, currentStep > 0 else { return }
        currentStep -= 1
    }

    private func startCalculation() {
        isCalculating = true

        Task {
            let profile = buildUserProfile()
            try? await userRepository.saveUserProfile(profile)

            try? await Task.sleep(for: .seconds(2.5))

            isCalculating = false
            // Notify completion - MainCoordinator will handle Auth → Paywall → Home flow
            onboardingFinished?()
        }
    }

    private func buildUserProfile() -> UserProfile {
        let headspace = answers[.headspace].flatMap { UserProfile.Headspace(rawValue: $0) }
        let mentalMuscle = answers[.mentalMuscle].flatMap { UserProfile.MentalMuscle(rawValue: $0) }
        let responseToSetback = answers[.responseToSetback].flatMap {
            UserProfile.ResponseToSetback(rawValue: $0)
        }
        let habitGoal = answers[.habitGoal].flatMap { UserProfile.HabitGoal(rawValue: $0) }
        let aiCoachTone = answers[.aiCoachTone].flatMap { UserProfile.AICoachTone(rawValue: $0) }

        let overwhelmedFrequency = headspace.map { mapHeadspaceToOverwhelmed($0) } ?? .sometimes
        let primaryGoal = mentalMuscle?.rawValue ?? "Build a healthier mindset"

        return UserProfile(
            userName: "",
            primaryGoal: primaryGoal,
            overwhelmedFrequency: overwhelmedFrequency,
            headspace: headspace,
            mentalMuscle: mentalMuscle,
            responseToSetback: responseToSetback,
            habitGoal: habitGoal,
            aiCoachTone: aiCoachTone
        )
    }

    /// Legacy mapping for backward compatibility with PromptEngine
    private func mapHeadspaceToOverwhelmed(_ headspace: UserProfile.Headspace)
        -> UserProfile.OverwhelmedFrequency
    {
        switch headspace {
        case .overwhelmed: return .often
        case .restless: return .sometimes
        case .content: return .rarely
        case .focused: return .sometimes
        }
    }

    public func dismiss() {
        onboardingFinished?()
    }
}
