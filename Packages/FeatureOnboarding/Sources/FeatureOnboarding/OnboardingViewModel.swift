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
public final class OnboardingViewModel {
    private let userRepository: UserRepository
    private let signInService: SignInService
    private let authStateQuery: AuthStateQuery
    public var onboardingFinished: (() -> Void)?

    /// - Parameter usesEmbeddedNavigationStack: When `false`, the parent supplies `NavigationStack` (e.g. start funnel). Default `true` preserves standalone behavior.
    public var usesEmbeddedNavigationStack: Bool
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
        signInService: SignInService,
        authStateQuery: AuthStateQuery,
        onboardingFinished: (() -> Void)?,
        usesEmbeddedNavigationStack: Bool = true
    ) {
        self.userRepository = userRepository
        self.signInService = signInService
        self.authStateQuery = authStateQuery
        self.onboardingFinished = onboardingFinished
        self.usesEmbeddedNavigationStack = usesEmbeddedNavigationStack
    }

    /// Handles option tap: selection state, delayed advance. Caller (View) owns haptics and animation.
    /// - Parameters:
    ///   - option: The selected option string
    ///   - onAdvance: Closure to run when advancing (View wraps selectOption in withAnimation here)
    public func handleOptionSelected(_ option: String, onAdvance: @escaping () -> Void) {
        selectedOption = option
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            isGoingBack = false
            onAdvance()
            selectedOption = nil
        }
    }

    public func selectOption(_ option: String) {
        let question = questions[currentStep]
        answers[question.logic] = option

        if currentStep < questions.count - 1 {
            currentStep += 1
        } else {
            finishOnboarding()
        }
    }

    /// Previously selected answer for the current step (e.g. when user went back). Nil if not yet answered.
    public var selectedAnswerForCurrentStep: String? {
        guard currentStep < questions.count else { return nil }
        return answers[questions[currentStep].logic]
    }

    /// Only display when our View``usesEmbeddedNavigationStack`` that has back button
    public var shouldDisplayDismissButton: Bool {
        usesEmbeddedNavigationStack
    }

    /// True when the back button should be shown (not calculating and not on first step) && when our View already ``usesEmbeddedNavigationStack``
    public var isBackButtonDisplayed: Bool {
        !isCalculating && currentStep > 0 && usesEmbeddedNavigationStack
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

    private func finishOnboarding() {
        isCalculating = true

        Task {
            async let delay: Void = delayForAnalyzing()
            
            try? await updateOrCreateNewAnonymousUser(isOnboardingComplete: true)

            _ = await delay

            isCalculating = false

            onboardingFinished?()
        }
    }

    private func updateOrCreateNewAnonymousUser(isOnboardingComplete: Bool) async throws {
        var user: UserProfile
        // Check if user exists
        if let userProfile = try? await userRepository.fetchUserProfile() {
            user = userProfile
        } else {
            // Else sign-in user anonymously and use that new id
            let userId = try await signInService.signIn(with: .anonymous)
            user = UserProfile.anonymousUser(id: userId)
        }

        user.onboarding(isComplete: isOnboardingComplete)
        user.update(with: getOnboardingData())
        try? await userRepository.saveUserProfile(user)
    }

    private func delayForAnalyzing() async {
        try? await Task.sleep(for: .seconds(2))
    }

    private func getOnboardingData() -> OnboardingData {
        let headspace = answers[.headspace].flatMap { OnboardingData.Headspace(rawValue: $0) }
        let mentalMuscle = answers[.mentalMuscle].flatMap { OnboardingData.MentalMuscle(rawValue: $0) }
        let responseToSetback = answers[.responseToSetback].flatMap {
            OnboardingData.ResponseToSetback(rawValue: $0)
        }
        let mindsetGoal = answers[.mindsetGoal].flatMap { OnboardingData.MindsetGoal(rawValue: $0) }
        let aiCoachTone = answers[.aiCoachTone].flatMap { OnboardingData.AICoachTone(rawValue: $0) }

        let overwhelmFrequency = headspace.map { mapHeadspaceToOverwhelmed($0) } ?? .sometimes
        let primaryGoal = mentalMuscle?.rawValue ?? "Build a healthier mindset"

        return OnboardingData(overwhelmFrequency: overwhelmFrequency.rawValue, headspace: headspace, mentalMuscle: mentalMuscle, responseToSetback: responseToSetback, mindsetGoal: mindsetGoal, aiCoachTone: aiCoachTone)
    }

    /// Legacy mapping for backward compatibility with PromptEngine
    private func mapHeadspaceToOverwhelmed(_ headspace: OnboardingData.Headspace)
        -> OnboardingData.OverwhelmedFrequency
    {
        switch headspace {
        case .overwhelmed: return .often
        case .restless: return .sometimes
        case .content: return .rarely
        case .focused: return .sometimes
        }
    }

    public func skipOnboarding() {
        onboardingFinished?()
        Task {
            try? await updateOrCreateNewAnonymousUser(isOnboardingComplete: false)
        }
    }
    
    // MARK: - Auth Helpers
    
    private func isAuthenticated() -> Bool {
        authStateQuery.isAuthenticated()
    }
}
