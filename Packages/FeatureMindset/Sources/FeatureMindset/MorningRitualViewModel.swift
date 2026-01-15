//
//  MorningRitualViewModel.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/6/26.
//

import Core
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class MorningRitualViewModel {
    // Dependencies
    private let addMindsetUseCase: AddMindsetUseCase
    private let getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase
    private let userRepository: UserRepository
    private let subscriptionService: SubscriptionService
    private let promptEngine = PromptEngine()
    private let aiService: AIAnalysisService = MockAIService()

    // Dynamic Content
    public var prompts: [MindsetPrompt] = []
    public var currentStepIndex: Int = 0
    
    // User Answers & AI Reflections (Keyed by Prompt ID)
    public var answers: [String: String] = [:]
    public var reflections: [String: String] = [:] // Store reflections per prompt
    
    // UI State
    public var isLoading: Bool = false
    public var yesterdayGoal: String?
    public var isShowingPaywall: Bool = false
    public var onNavigate: ((NavigationState) -> Void)?
    
    public var isAiThinking: Bool = false
    public var earnedXP: Int = 0
    public var generatedArchetype: String = "The Explorer"
    public var isShowingSuccess: Bool = false

    public var currentAiReflection: String? {
        guard let id = currentPrompt?.id else { return nil }
        return reflections[id]
    }
    
    public enum NavigationState {
        case success(archetype: String, xp: Int)
        case paywall
    }

    public init(
        userRepository: UserRepository,
        addMindsetUseCase: AddMindsetUseCase,
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase,
        subscriptionService: SubscriptionService,
        onNavigate: ((NavigationState) -> Void)?
    ) {
        self.userRepository = userRepository
        self.addMindsetUseCase = addMindsetUseCase
        self.getYesterdayBridgeUseCase = getYesterdayBridgeUseCase
        self.subscriptionService = subscriptionService
        self.onNavigate = onNavigate
        
        Task { await prepareRitual() }
    }

    private func prepareRitual() async {
        isLoading = true
        do {
            if let profile = try await userRepository.fetchUserProfile() {
                self.prompts = promptEngine.fetchPrompts(for: profile, completedCount: 0)
            }
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
        
        HapticManager.impact(.medium) // Feel the "Submit"
        isAiThinking = true
        
        do {
            let reflection = try await aiService.generateFeedback(for: prompt, answer: answer)
            reflections[prompt.id] = reflection // Save reflection for this specific prompt
        } catch {
            reflections[prompt.id] = "That's a thoughtful reflection. Keep going!"
        }
        HapticManager.notification(.success)
        isAiThinking = false
    }
    
    // MARK: - Completion

    public func completeRitual() async {
        isLoading = true
        
        do {
            // 1. Map current answers and reflections into PromptResponse objects
            let currentResponses = prompts.compactMap { prompt -> PromptResponse? in
                guard let answer = answers[prompt.id] else { return nil }
                return PromptResponse(
                    promptId: prompt.id,
                    category: prompt.category,
                    userText: answer,
                    aiReflection: reflections[prompt.id]
                )
            }
            
            // 2. Calculate Gamification Data
            // Sum XP based on categories used in this session
            self.earnedXP = currentResponses.reduce(0) { $0 + $1.category.xpValue }
            
            // Determine Archetype by finding the most frequent category performed
            let categoryCounts = currentResponses.reduce(into: [:]) { counts, res in
                counts[res.category, default: 0] += 1
            }
            
            if let primaryCategory = categoryCounts.max(by: { $0.value < $1.value })?.key {
                self.generatedArchetype = "The \(primaryCategory.displayName)"
            }
            
            // 3. Create and Save the Parent MindsetEntry
            let entry = MindsetEntry(
                responses: currentResponses,
                archetypeTag: self.generatedArchetype,
                sentimentScore: 0.8 // In production, this would come from an AI sentiment analysis call
            )
            
            try await addMindsetUseCase.execute(entry: entry)
            
            // 4. Handle Subscription Gate and Navigation
            let isPremium = await subscriptionService.checkSubscriptionStatus()
            
            if isPremium {
                onNavigate?(.success(archetype: generatedArchetype, xp: earnedXP))
            } else {
                onNavigate?(.paywall)
            }
            
        } catch {
            print("Save failed: \(error)")
        }
        
        isLoading = false
    }
}
