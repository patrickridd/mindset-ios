//
//  OnboardingViewModel.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/11/26.
//

import Foundation
import Domain
import Observation

@Observable
@MainActor
public final class OnboardingViewModel {
    private let userRepository: UserRepository
    public var onboardingFinished: ((NavigationState) -> Void)?

    public var currentStep = 0
    public var isCalculating = false
    
    /// Captured answers (option strings), keyed by question logic
    private var answers: [OnboardingQuestion.Logic: String] = [:]

    public let questions = OnboardingQuestion.allQuestions

    public enum NavigationState {
        case paywall
        case home
    }

    public init(userRepository: UserRepository, onboardingFinished: ((NavigationState) -> Void)?) {
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

    private func startCalculation() {
        isCalculating = true
        
        Task {
            let profile = buildUserProfile()
            try? await userRepository.saveUserProfile(profile)
            
            try? await Task.sleep(for: .seconds(2.5))
            
            isCalculating = false
            onboardingFinished?(.paywall)
        }
    }
    
    private func buildUserProfile() -> UserProfile {
        let headspace = answers[.headspace].flatMap { UserProfile.Headspace(rawValue: $0) }
        let mentalMuscle = answers[.mentalMuscle].flatMap { UserProfile.MentalMuscle(rawValue: $0) }
        let responseToSetback = answers[.responseToSetback].flatMap { UserProfile.ResponseToSetback(rawValue: $0) }
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
    private func mapHeadspaceToOverwhelmed(_ headspace: UserProfile.Headspace) -> UserProfile.OverwhelmedFrequency {
        switch headspace {
        case .overwhelmed: return .often
        case .restless: return .sometimes
        case .content: return .rarely
        case .focused: return .sometimes
        }
    }

    public func dismiss() {
        onboardingFinished?(.home)
    }
}
