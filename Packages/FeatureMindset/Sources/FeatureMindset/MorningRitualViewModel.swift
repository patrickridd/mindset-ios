//
//  MorningRitualViewModel.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import Foundation
import Observation
import SharedLocalization

@MainActor
@Observable
public final class MorningRitualViewModel {
    // Dependencies
    private let getStreakUseCase: GetStreakUseCase
    private let addMindsetUseCase: AddMindsetUseCase
    private let userRepository: UserRepository
    private let subscriptionService: SubscriptionService
    private let promptEngine = PromptEngine()
    private let aiService: AIAnalysisService
    private let logger: AppLogger

    // Dynamic Content
    public var prompts: [MindsetPrompt] = []
    public var currentStepIndex: Int = 0

    // User Answers & AI Reflections (Keyed by Prompt ID)
    public var answers: [String: String] = [:]
    public var reflections: [String: String] = [:]  // Store reflections per prompt

    // Typewriter Animation State
    public var animatedPromptIds: Set<String> = []
    public var isGeneratingPrompt: Bool = false

    // UI State
    public var isLoading: Bool = false
    public var isRitualComplete: Bool = false
    public var isShowingPaywall: Bool = false
    public var isCoachTipVisible: Bool = false
    public var isCurrentPromptSubmitted: Bool = false
    public var maxProgressAchieved: Double = 0.0
    public var isRitualCompleteAnimationDone: Bool = false
    
    public var onNavigate: ((NavigationState) -> Void)?

    public var isAiThinking: Bool = false
    public var earnedXP: Int = 0
    public var generatedArchetype: String = "The Explorer"
    private var onDismiss: (() -> Void)?
    private var isPro: Bool = false

    public var shouldShowTextField: Bool {
        currentStepIndex < prompts.count
    }

    public var currentAiReflection: String? {
        guard let id = currentPrompt?.id else { return nil }
        return reflections[id]
    }

    public var shouldAnimateCurrentPrompt: Bool {
        guard let promptId = currentPrompt?.id else { return false }
        return !isGeneratingPrompt && !animatedPromptIds.contains(promptId)
    }
    
    public var  displayRitualSuccessAnimation: Bool {
        isRitualComplete && !isRitualCompleteAnimationDone
    }

    public enum NavigationState {
        case success(archetype: String, xp: Int)
        case paywall
    }

    public init(
        userRepository: UserRepository,
        addMindsetUseCase: AddMindsetUseCase,
        subscriptionService: SubscriptionService,
        getStreakUseCase: GetStreakUseCase,
        aiService: AIAnalysisService,
        logger: AppLogger,
        onNavigate: ((NavigationState) -> Void)?,
        onDismiss: (() -> Void)? = nil
    ) {
        self.userRepository = userRepository
        self.addMindsetUseCase = addMindsetUseCase
        self.subscriptionService = subscriptionService
        self.getStreakUseCase = getStreakUseCase
        self.aiService = aiService
        self.logger = logger
        self.onNavigate = onNavigate
        self.onDismiss = onDismiss
        Task {
            self.isPro = await subscriptionService.checkSubscriptionStatus()
        }
        Task {
            await prepareRitual()
        }  
    }

    public func dismiss() {
        onDismiss?()
    }

    private func prepareRitual() async {
        isLoading = true
        // Reset local state for a fresh start
        self.currentStepIndex = 0
        self.answers = [:]
        self.reflections = [:]
        self.isCurrentPromptSubmitted = false
        self.maxProgressAchieved = 0.0
        self.animatedPromptIds = []
        self.isGeneratingPrompt = false

        do {
            let profile = try await userRepository.fetchUserProfile()

            // Ensure we pass the actual completedCount if you have it, or 0 for now
            let newPrompts = promptEngine.fetchPrompts(for: profile, completedCount: 0)

            // Assigning to self.prompts triggers the UI update
            self.prompts = newPrompts
        } catch {
            logger.log("❌ Ritual setup failed: \(error.localizedDescription)")
            self.prompts = promptEngine.fetchPrompts(for: nil, completedCount: 0)
        }
        isLoading = false

        // Trigger generation animation for first prompt
        await startPromptGeneration()
    }

    // MARK: - Navigation Logic

    public var currentPrompt: MindsetPrompt? {
        guard !prompts.isEmpty, currentStepIndex < prompts.count else { return nil }
        return prompts[currentStepIndex]
    }

    public var canProceed: Bool {
        guard let currentId = currentPrompt?.id else { return false }
        let currentAnswerCount = answers[currentId]?.count ?? 0
        return currentAnswerCount >= 3
    }

    /// Progress for the step progress bar (0...1). First step shows a small nub (0.025).
    public var progress: Double {
        guard !prompts.isEmpty else { return 0 }
        let baseProgress = Double(currentStepIndex) / Double(prompts.count)
        if isCurrentPromptSubmitted && currentStepIndex < prompts.count - 1 {
            // If current prompt is submitted, and it's not the last step, show progress for the next step
            maxProgressAchieved = max(
                maxProgressAchieved, Double(currentStepIndex + 1) / Double(prompts.count))
        } else if isCurrentPromptSubmitted && currentStepIndex == prompts.count - 1 {
            // If it's the last step and submitted, show full progress
            maxProgressAchieved = max(maxProgressAchieved, 1.0)
        } else {
            maxProgressAchieved = max(maxProgressAchieved, baseProgress)
        }
        return maxProgressAchieved
    }

    public var shouldDisplayFooterButton: Bool {
        return isCurrentPromptSubmitted
    }

    public var isLastStep: Bool {
        return currentStepIndex >= prompts.count - 1
    }

    public var footerButtonText: String {
        if isAiThinking {
            return FeatureMindsetStrings.MorningRitual.analyzing
        } else if isLastStep {
            return FeatureMindsetStrings.MorningRitual.complete
        } else {
            return SharedLocalizedString.continue
        }
    }

    public var showFooterButtonEnabledStyle: Bool {
        return !isAiThinking
    }

    public var isFooterButtonDisabled: Bool {
        return isAiThinking
    }

    public func nextStep() {
        isCoachTipVisible = false
        isCurrentPromptSubmitted = false
        if currentStepIndex < prompts.count - 1 {
            currentStepIndex += 1
            Task {
                await startPromptGeneration()
            }
        } else {
            isRitualComplete = true
            Task {
                try? await saveMindsetEntry()
            }
        }
    }

    public func toggleCoachTip() {
        isCoachTipVisible.toggle()
    }

    public func markCurrentPromptAnimated() {
        guard let promptId = currentPrompt?.id else { return }
        animatedPromptIds.insert(promptId)
    }

    private func startPromptGeneration() async {
        isGeneratingPrompt = true
        try? await Task.sleep(for: .seconds(1.0))
        isGeneratingPrompt = false
    }

    public func submitCurrentAnswer() async {
        guard let prompt = currentPrompt, let answer = answers[prompt.id] else { return }

        isCurrentPromptSubmitted = true
        isAiThinking = true

        do {
            let reflection = try await aiService.generateFeedback(for: prompt, answer: answer)
            reflections[prompt.id] = reflection  // Save reflection for this specific prompt
        } catch {
            reflections[prompt.id] = "That's a thoughtful reflection. Keep going!"
        }
        isAiThinking = false
    }

    public var loadingDescription: String {
        if isRitualComplete {
            return FeatureMindsetStrings.MorningRitual.ritualSuccessLoading
        } else {
            return FeatureMindsetStrings.MorningRitual.designingRitual
        }
    }

    // MARK: - Completion

    public func saveMindsetEntry() async throws {
        do {
            guard let userId = try await userRepository.fetchUserProfile()?.id else {
                logger.log("🚨 userId not found, aborting saveMindsetEntry")
                return
            }

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
            // Create and Save the Parent MindsetEntry
            let dateCreated = Date()
            let entry = Entry(
                userId: userId,
                dateCreated: dateCreated,
                promptResponses: currentResponses,
                archetypeTag: self.generatedArchetype,
                sentimentScore: 0.8  // In production, this would come from an AI sentiment analysis call
            )
            
            //  Save the entry to the database
            try await addMindsetUseCase.execute(entry: entry)
            
            // This ensures the streak is mathematically correct, even if they skipped a day.
            let updatedStreak = try await getStreakUseCase.execute()
            
            // Update the User Profile
            if var profile = try await userRepository.fetchUserProfile() {
                profile.stats.streakCount = updatedStreak
                profile.stats.totalXP += self.earnedXP
                profile.stats.lastRitualDate = dateCreated
                try await userRepository.saveUserProfile(profile)
                
                logger.log("✅ Entry saved. New Streak: \(updatedStreak), XP: \(profile.stats.totalXP)")
            }
        } catch {
            logger.log("❌ Ritual save failed: \(error.localizedDescription)")
        }
    }

    public func completeRitual() {
        if isPro {
            onNavigate?(.success(archetype: generatedArchetype, xp: earnedXP))
        } else {
            onNavigate?(.paywall)
        }
    }
}
