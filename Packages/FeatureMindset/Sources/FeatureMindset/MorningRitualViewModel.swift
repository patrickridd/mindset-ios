//
//  MorningRitualViewModel.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/6/26.
//

import Foundation
import Domain
import Observation

@MainActor
@Observable
public final class MorningRitualViewModel {
    public enum RitualStep: Int, CaseIterable {
        case gratitude, goal, affirmation
    }
    
    // Current Progress
    public var currentStep: RitualStep = .gratitude
    
    // Input Data
    public var gratitudeText: String = ""
    public var goalText: String = ""
    public var affirmationText: String = ""
    
    // Status
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var yesterdayGoal: String?
    
    // UseCases
    private let addMindsetUseCase: AddMindsetUseCase
    private let getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase
    private let generateArchetypeUseCase = GenerateArchetypeUseCase()

    public var generatedArchetype: String?
    public var isShowingSuccess: Bool = false
    
    public var isShowingPaywall: Bool = false
    private let subscriptionService: SubscriptionService
    
    public init(
        addMindsetUseCase: AddMindsetUseCase,
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase,
        subscriptionService: SubscriptionService
    ) {
        self.addMindsetUseCase = addMindsetUseCase
        self.getYesterdayBridgeUseCase = getYesterdayBridgeUseCase
        self.subscriptionService = subscriptionService
        
        // Fetch the bridge data immediately
        Task { await fetchYesterdayBridge() }
    }
    
    /// Determines if the user has provided enough input to move to the next step
    public var canProceed: Bool {
        switch currentStep {
        case .gratitude:
            return gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
        case .goal:
            return goalText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
        case .affirmation:
            return affirmationText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
        }
    }

    private func fetchYesterdayBridge() async {
        do {
            self.yesterdayGoal = try await getYesterdayBridgeUseCase.execute()
        } catch {
            print("Bridge failed: \(error)")
        }
    }

    // Actions
    public func nextStep() {
        if let next = RitualStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
    
    public func completeRitual() async {
        isLoading = true
        
        // 1. Generate the Identity
        let archetype = generateArchetypeUseCase.execute(
            gratitude: gratitudeText,
            goal: goalText
        )
        self.generatedArchetype = archetype
        
        do {
            // 2. Save to Data Layer (including the tag)
            try await addMindsetUseCase.execute(
                gratitude: gratitudeText,
                goal: goalText,
                affirmation: affirmationText
            )
            
            // 3. The Gate check
            let isPremium = await subscriptionService.checkSubscriptionStatus()
            
            if isPremium {
                self.isShowingSuccess = true
            } else {
                // This triggers the Paywall sheet
                self.isShowingPaywall = true
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        defer {
            isLoading = false
        }
    }
}
