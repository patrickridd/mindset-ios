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
    // Dependencies
    private let addMindsetUseCase: AddMindsetUseCase
    private let getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase
    private let userRepository: UserRepository // Needed to get profile for PromptEngine
    private let subscriptionService: SubscriptionService
    private let promptEngine = PromptEngine()
    private let aiService: AIAnalysisService = MockAIService() // Injected in production

    // Dynamic Content
    public var prompts: [MindsetPrompt] = []
    public var currentStepIndex: Int = 0
    
    // User Answers (Keyed by Prompt ID)
    public var answers: [String: String] = [:]
    
    // UI State
    public var isLoading: Bool = false
    public var yesterdayGoal: String?
    public var isShowingPaywall: Bool = false
    public var onComplete: (() -> Void)?
    public var aiReflection: String?
    public var isAiThinking: Bool = false
    
    public init(
        userRepository: UserRepository,
        addMindsetUseCase: AddMindsetUseCase,
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase,
        subscriptionService: SubscriptionService,
        onComplete: (() -> Void)? = nil
    ) {
        self.userRepository = userRepository
        self.addMindsetUseCase = addMindsetUseCase
        self.getYesterdayBridgeUseCase = getYesterdayBridgeUseCase
        self.subscriptionService = subscriptionService
        self.onComplete = onComplete
        
        Task { await prepareRitual() }
    }

    private func prepareRitual() async {
        isLoading = true
        do {
            // 1. Get the Profile to customize prompts
            if let profile = try await userRepository.fetchUserProfile() {
                // 2. Engine decides which science-backed prompts to show
                self.prompts = promptEngine.fetchPrompts(for: profile, completedCount: 0)
            }
            
            // 3. Get the "Yesterday Bridge"
            self.yesterdayGoal = try await getYesterdayBridgeUseCase.execute()
        } catch {
            print("Setup failed: \(error)")
        }
        isLoading = false
    }

    // MARK: - Navigation Logic
    
    public var currentPrompt: MindsetPrompt? {
        guard currentStepIndex < prompts.count else { return nil }
        return prompts[currentStepIndex]
    }

    public var canProceed: Bool {
        guard let currentId = currentPrompt?.id else { return false }
        return (answers[currentId]?.count ?? 0) >= 3
    }

    public func nextStep() {
        if currentStepIndex < prompts.count - 1 {
            currentStepIndex += 1
        } else {
            Task { await completeRitual() }
        }
    }

    public func submitCurrentAnswer() async {
        guard let prompt = currentPrompt, let answer = answers[prompt.id] else { return }
        
        isAiThinking = true
        aiReflection = nil // Reset
        
        do {
            // Call the service we created
            aiReflection = try await aiService.generateFeedback(for: prompt, answer: answer)
        } catch {
            aiReflection = "That's a thoughtful reflection. Keep going!"
        }
        
        isAiThinking = false
    }
    
    // MARK: - Completion
    
    public func completeRitual() async {
        isLoading = true
        
        // In the next phase, we'll iterate 'answers' and send them to the AI
        // For now, we save the primary entry
        do {
            try await addMindsetUseCase.execute(
                // We'll map your answers dictionary to the save call
                gratitude: answers.values.first ?? "",
                goal: "",
                affirmation: "",
                archetypeTag: "The Explorer"
            )
            
            let isPremium = await subscriptionService.checkSubscriptionStatus()
            if isPremium {
                onComplete?()
            } else {
                isShowingPaywall = true
            }
        } catch {
            print("Save failed: \(error)")
        }
        isLoading = false
    }
}
