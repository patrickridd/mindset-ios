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
    public var onboardingFinished: (() -> Void)?

    public var currentStep = 0
    public var isCalculating = false
    
    // Captured Data
    public var primaryFocus: String = ""
    public var overwhelmFrequency: String = ""
    public var consistencyBlocker: String = ""
    public var bestSelfName: String = ""

    public init(userRepository: UserRepository, onboardingFinished: (() -> Void)?) {
        self.userRepository = userRepository
        self.onboardingFinished = onboardingFinished
    }

    public let questions = [
        "What is your primary focus right now?",
        "How often do you feel overwhelmed?",
        "What stops your consistency?",
        "What's one word for your 'Best Self'?"
    ]

    public func selectOption(_ option: String) {
        // Record data based on step
        switch currentStep {
        case 0: primaryFocus = option
        case 1: overwhelmFrequency = option
        case 2: consistencyBlocker = option
        case 3: bestSelfName = option
        default: break
        }

        if currentStep < questions.count - 1 {
            currentStep += 1
        } else {
            startCalculation()
        }
    }

    private func startCalculation() {
        isCalculating = true
        
        Task {
            // Save to SwiftData via Repository
            let profile = UserProfile(
                bestSelfName: bestSelfName,
                primaryGoal: primaryFocus,
                overwhelmedFrequency: UserProfile.OverwhelmedFrequency(rawValue: overwhelmFrequency) ?? .sometimes
            )
            try? await userRepository.saveUserProfile(profile)
            
            // Artificial delay for "Perceived Value"
            try? await Task.sleep(for: .seconds(2.5))
            
            isCalculating = false
            onboardingFinished?()
        }
    }
}
