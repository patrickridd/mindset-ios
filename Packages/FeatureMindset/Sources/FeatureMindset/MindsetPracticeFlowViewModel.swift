//
//  MindsetPracticeFlowViewModel.swift
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
public final class MindsetPracticeFlowViewModel {
    private static let minimumAnswerLength = 3
    private static let todayGoalsPromptId = PromptType.todoToday.id

    // Dependencies
    private let getStreakUseCase: GetStreakUseCase
    private let addEntryUseCase: AddEntryUseCase
    private let userRepository: UserRepository
    private let subscriptionService: SubscriptionService
    private let promptEngine = PromptEngine()
    private let aiService: AIAnalysisService
    private let logger: AppLogger
    
    // Dynamic Content
    public var prompts: [Prompt] = []
    /// Index into `prompts` (logical prompt).
    public var currentPromptIndex: Int = 0
    /// Slot within the current logical prompt (0 ..< responseSlotCount).
    public var currentSlotIndex: Int = 0

    // Keyed by Prompt ID, value is an array of strings (one per slot)
    public var answers: [String: [String]] = [:]
    // [PromptId: AI Reflection]
    public var reflections: [String: String] = [:]

    // Typewriter Animation State
    public var animatedPromptIds: Set<String> = []
    public var isGeneratingPrompt: Bool = false

    /// Brief shimmer on the answer field after advancing to the next slot within the same prompt.
    public var isInterSlotTextFieldShimmering: Bool = false
    private var interSlotShimmerTask: Task<Void, Never>?

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
        currentPromptIndex < prompts.count && !isCurrentPromptSubmitted && !isAiThinking
    }

    public var currentAiReflection: String? {
        guard let id = currentPrompt?.id else { return nil }
        return reflections[id]
    }

    /// Accessor for the text currently being typed in the active slot
    public var currentInputText: String {
        get {
            guard let id = currentPrompt?.id else { return "" }
            let promptAnswers = answers[id] ?? []
            return promptAnswers.indices.contains(currentSlotIndex) ? promptAnswers[currentSlotIndex] : ""
        }
        set {
            guard let id = currentPrompt?.id else { return }
            var promptAnswers = answers[id] ?? Array(repeating: "", count: currentPrompt?.responseSlotCount ?? 1)
            if promptAnswers.indices.contains(currentSlotIndex) {
                promptAnswers[currentSlotIndex] = newValue
                answers[id] = promptAnswers
            }
        }
    }
    
    public var slotPositionLabel: String? {
        guard let prompt = currentPrompt, prompt.responseSlotCount > 1 else { return nil }
        return "\(currentSlotIndex + 1) / \(prompt.responseSlotCount)"
    }
    
    public var canProceed: Bool {
        guard let prompt = currentPrompt, let currentAnswers = answers[prompt.id] else { return false }
        
        // If it's a "bulk" prompt (like today goals), check all slots
        if isTodayGoalsPrompt(prompt) {
            return currentAnswers.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= Self.minimumAnswerLength }
        }
        
        // Otherwise, just check the current slot
        let currentText = currentAnswers[currentSlotIndex]
        return currentText.trimmingCharacters(in: .whitespacesAndNewlines).count >= Self.minimumAnswerLength
    }
    
    // MARK: - Actions
    
    public func submitCurrentAnswer() async {
        guard let prompt = currentPrompt else { return }
        guard canProceed else { return }
        
        let isLastSlot = currentSlotIndex >= prompt.responseSlotCount - 1
        
        if !isLastSlot {
            currentSlotIndex += 1
            beginInterSlotTextFieldShimmer()
            return
        }
        
        // Handle logical prompt completion
        isCurrentPromptSubmitted = true
        isAiThinking = true
        
        let allAnswersForPrompt = answers[prompt.id] ?? []
        let combinedText = allAnswersForPrompt.enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
        
        do {
            let reflection = try await aiService.generateFeedback(for: prompt, answer: combinedText)
            reflections[prompt.id] = reflection
        } catch {
            reflections[prompt.id] = "That's a thoughtful reflection. Keep going!"
        }
        isAiThinking = false
    }
    
    // MARK: - Save Logic
    
    public func saveEntry() async throws {
        do {
            guard let userId = try await userRepository.fetchUserProfile()?.id else { return }
            
            // Cleanly map prompts to our new PromptResponse model
            let currentResponses: [PromptResponse] = prompts.compactMap { prompt in
                guard let promptAnswers = answers[prompt.id],
                      !promptAnswers.allSatisfy({ $0.isEmpty }) else { return nil }
                
                return PromptResponse(
                    promptId: prompt.id,
                    category: prompt.category,
                    answers: promptAnswers,
                    aiReflection: reflections[prompt.id]
                )
            }
            
            self.earnedXP = RitualGamification.earnedXP(from: currentResponses)
            
            if let primaryCategory = RitualGamification.primaryCategory(from: currentResponses) {
                self.generatedArchetype = "The \(primaryCategory.displayName)"
            }
            
            let entry = Entry(
                userId: userId,
                dateCreated: Date(),
                promptResponses: currentResponses,
                archetypeTag: self.generatedArchetype,
                sentimentScore: 0.8
            )
            
            try await addEntryUseCase.execute(entry: entry)
            // ... update profile logic ...
            
        } catch {
            logger.log("❌ Ritual save failed: \(error.localizedDescription)")
        }
    }
    
    private func isTodayGoalsPrompt(_ prompt: Prompt) -> Bool {
        prompt.id == Self.todayGoalsPromptId
    }

    public var totalMicroSteps: Int {
        prompts.reduce(0) { $0 + $1.responseSlotCount }
    }

    private var completedSlotsBeforeCurrentPrompt: Int {
        prompts.prefix(currentPromptIndex).reduce(0) { $0 + $1.responseSlotCount }
    }

    public var shouldAnimateCurrentPrompt: Bool {
        guard let key = currentPrompt?.id else { return false }
        return !isGeneratingPrompt && !animatedPromptIds.contains(key)
    }

    public var displayRitualSuccessAnimation: Bool {
        isRitualComplete && !isRitualCompleteAnimationDone
    }

    public enum NavigationState {
        case success(archetype: String, xp: Int)
        case paywall
    }

    public init(
        userRepository: UserRepository,
        addEntryUseCase: AddEntryUseCase,
        subscriptionService: SubscriptionService,
        getStreakUseCase: GetStreakUseCase,
        aiService: AIAnalysisService,
        logger: AppLogger,
        onNavigate: ((NavigationState) -> Void)?,
        onDismiss: (() -> Void)? = nil
    ) {
        self.userRepository = userRepository
        self.addEntryUseCase = addEntryUseCase
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
        self.currentPromptIndex = 0
        self.currentSlotIndex = 0
        self.answers = [:]
        self.reflections = [:]
        self.isCurrentPromptSubmitted = false
        self.maxProgressAchieved = 0.0
        self.animatedPromptIds = []
        self.isGeneratingPrompt = false
        cancelInterSlotShimmerTask()
        self.isInterSlotTextFieldShimmering = false

        do {
            let profile = try await userRepository.fetchUserProfile()
            self.prompts = promptEngine.fetchPrompts(for: profile, completedCount: 0)
        } catch {
            logger.log("❌ Ritual setup failed: \(error.localizedDescription)")
            self.prompts = promptEngine.fetchPrompts(for: nil, completedCount: 0)
        }
        isLoading = false

        await startPromptGeneration()
    }

    // MARK: - Navigation Logic

    public var currentPrompt: Prompt? {
        guard !prompts.isEmpty, currentPromptIndex < prompts.count else { return nil }
        return prompts[currentPromptIndex]
    }

    /// Progress for the step progress bar (0...1). Uses sequential micro-steps; first step shows a small nub (0.025).
    public var progress: Double {
        guard !prompts.isEmpty, totalMicroSteps > 0 else { return 0 }
        let slotsFilled: Int
        if isCurrentPromptSubmitted, let p = currentPrompt {
            slotsFilled = completedSlotsBeforeCurrentPrompt + p.responseSlotCount
        } else {
            slotsFilled = completedSlotsBeforeCurrentPrompt + currentSlotIndex
        }
        let base = Double(slotsFilled) / Double(totalMicroSteps)
        if slotsFilled == 0 && !isCurrentPromptSubmitted {
            maxProgressAchieved = max(maxProgressAchieved, 0.025)
        } else {
            maxProgressAchieved = max(maxProgressAchieved, base)
        }
        return maxProgressAchieved
    }

    public var shouldDisplayFooterButton: Bool {
        isCurrentPromptSubmitted
    }

    public var isLastStep: Bool {
        currentPromptIndex >= prompts.count - 1
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
    
    public var loadingDescription: String {
        if isRitualComplete {
            return FeatureMindsetStrings.MorningRitual.ritualSuccessLoading
        } else {
            return FeatureMindsetStrings.MorningRitual.designingRitual
        }
    }

    public var showFooterButtonEnabledStyle: Bool {
        !isAiThinking
    }

    public var isFooterButtonDisabled: Bool {
        isAiThinking
    }

    public func nextStep() {
        isCoachTipVisible = false
        isCurrentPromptSubmitted = false
        cancelInterSlotShimmerTask()
        isInterSlotTextFieldShimmering = false
        if currentPromptIndex < prompts.count - 1 {
            currentPromptIndex += 1
            currentSlotIndex = 0
            Task {
                await startPromptGeneration()
            }
        } else {
            isRitualComplete = true
            Task {
                try? await saveEntry()
            }
        }
    }

    public func toggleCoachTip() {
        isCoachTipVisible.toggle()
    }

    public func markCurrentPromptAnimated() {
        guard let key = currentPrompt?.id else { return }
        animatedPromptIds.insert(key)
    }

    private func startPromptGeneration() async {
        isGeneratingPrompt = true
        try? await Task.sleep(for: .seconds(1.0))
        isGeneratingPrompt = false
    }

    private func cancelInterSlotShimmerTask() {
        interSlotShimmerTask?.cancel()
        interSlotShimmerTask = nil
    }

    private func beginInterSlotTextFieldShimmer() {
        cancelInterSlotShimmerTask()
        isInterSlotTextFieldShimmering = true
        interSlotShimmerTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            isInterSlotTextFieldShimmering = false
            interSlotShimmerTask = nil
        }
    }

    // MARK: - Completion

    public func completeRitual() {
        if isPro {
            onNavigate?(.success(archetype: generatedArchetype, xp: earnedXP))
        } else {
            onNavigate?(.paywall)
        }
    }
}
