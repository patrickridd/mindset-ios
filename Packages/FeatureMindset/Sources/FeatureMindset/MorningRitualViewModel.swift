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
    
    // Dependencies (Injected via Use Cases)
    private let addMindsetUseCase: AddMindsetUseCase
    private let getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase
    private let subscriptionService: SubscriptionService
    private let generateArchetypeUseCase = GenerateArchetypeUseCase()
    
    // UI State
    public var currentStep: RitualStep = .gratitude
    public var gratitudeText: String = ""
    public var goalText: String = ""
    public var affirmationText: String = ""
    public var yesterdayGoal: String?
    
    // Status
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var generatedArchetype: String?
    public var isShowingSuccess: Bool = false
    public var isShowingPaywall: Bool = false

    public var onRitualFinished: () -> Void

    public init(
        addMindsetUseCase: AddMindsetUseCase,
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase,
        subscriptionService: SubscriptionService,
        onRitualFinished: @escaping () -> Void = { }
    ) {
        self.addMindsetUseCase = addMindsetUseCase
        self.getYesterdayBridgeUseCase = getYesterdayBridgeUseCase
        self.subscriptionService = subscriptionService
        self.onRitualFinished = onRitualFinished

        // Fetch the bridge data immediately to show "Yesterday you said..."
        Task { await fetchYesterdayBridge() }
    }
    
    public var canProceed: Bool {
        let text: String
        switch currentStep {
        case .gratitude: text = gratitudeText
        case .goal: text = goalText
        case .affirmation: text = affirmationText
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }
    
    private func fetchYesterdayBridge() async {
        do {
            // This UseCase talks to MindsetRepository.getLatestEntry()
            self.yesterdayGoal = try await getYesterdayBridgeUseCase.execute()
        } catch {
            print("Bridge failed: \(error)")
        }
    }
    
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
            // 2. Save via UseCase (which maps to our Repository)
            try await addMindsetUseCase.execute(
                gratitude: gratitudeText,
                goal: goalText,
                affirmation: affirmationText,
                archetypeTag: archetype
            )
            
            // 3. Subscription Gate
            let isPremium = await subscriptionService.checkSubscriptionStatus()
            
            if isPremium {
                self.isShowingSuccess = true
            } else {
                self.isShowingPaywall = true
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
