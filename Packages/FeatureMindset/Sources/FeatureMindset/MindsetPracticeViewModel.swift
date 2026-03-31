//
//  MindsetPracticeViewModel.swift
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
public final class MindsetPracticeViewModel {
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

    // User Answers & AI Reflections (answers keyed by composite id; reflections by logical prompt id)
    public var answers: [String: String] = [:]
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
        currentPromptIndex < prompts.count
    }

    public var currentAiReflection: String? {
        guard let id = currentPrompt?.id else { return nil }
        return reflections[id]
    }

    /// Composite storage key for the active slot (matches persisted `PromptResponse.promptId`).
    public var currentCompositeAnswerKey: String? {
        guard let prompt = currentPrompt else { return nil }
        return Prompt.compositePromptId(baseId: prompt.id, slotIndex: currentSlotIndex)
    }

    /// e.g. "2 of 3" when the logical prompt has multiple slots; `nil` for a single-slot prompt.
    public var slotPositionLabel: String? {
        guard let prompt = currentPrompt, prompt.responseSlotCount > 1 else { return nil }
        return "\(currentSlotIndex + 1) / \(prompt.responseSlotCount)"
    }

    public var totalMicroSteps: Int {
        prompts.reduce(0) { $0 + $1.responseSlotCount }
    }

    private var completedSlotsBeforeCurrentPrompt: Int {
        prompts.prefix(currentPromptIndex).reduce(0) { $0 + $1.responseSlotCount }
    }

    public var shouldAnimateCurrentPrompt: Bool {
        guard let key = currentCompositeAnswerKey else { return false }
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

    public var canProceed: Bool {
        guard let key = currentCompositeAnswerKey else { return false }
        let currentAnswerCount = answers[key]?.count ?? 0
        return currentAnswerCount >= 3
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
        guard let key = currentCompositeAnswerKey else { return }
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

    public func submitCurrentAnswer() async {
        guard let prompt = currentPrompt else { return }
        let key = Prompt.compositePromptId(baseId: prompt.id, slotIndex: currentSlotIndex)
        guard let answer = answers[key], answer.count >= 3 else { return }

        let isLastSlot = currentSlotIndex >= prompt.responseSlotCount - 1
        if !isLastSlot {
            currentSlotIndex += 1
            beginInterSlotTextFieldShimmer()
            return
        }

        isCurrentPromptSubmitted = true
        isAiThinking = true

        let combined = (0..<prompt.responseSlotCount).map { slot -> String in
            let slotKey = Prompt.compositePromptId(baseId: prompt.id, slotIndex: slot)
            return answers[slotKey] ?? ""
        }.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")

        do {
            let reflection = try await aiService.generateFeedback(for: prompt, answer: combined)
            reflections[prompt.id] = reflection
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

    public func saveEntry() async throws {
        do {
            guard let userId = try await userRepository.fetchUserProfile()?.id else {
                logger.log("🚨 userId not found, aborting saveEntry")
                return
            }

            var currentResponses: [PromptResponse] = []
            for prompt in prompts {
                for slot in 0..<prompt.responseSlotCount {
                    let cid = Prompt.compositePromptId(baseId: prompt.id, slotIndex: slot)
                    guard let text = answers[cid],
                        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    else { continue }
                    let reflection =
                        slot == prompt.responseSlotCount - 1 ? reflections[prompt.id] : nil
                    currentResponses.append(
                        PromptResponse(
                            promptId: cid,
                            category: prompt.category,
                            userText: text,
                            aiReflection: reflection
                        ))
                }
            }

            self.earnedXP = RitualGamification.earnedXP(from: currentResponses)

            if let primaryCategory = RitualGamification.primaryCategory(from: currentResponses) {
                self.generatedArchetype = "The \(primaryCategory.displayName)"
            }

            let dateCreated = Date()
            let entry = Entry(
                userId: userId,
                dateCreated: dateCreated,
                promptResponses: currentResponses,
                archetypeTag: self.generatedArchetype,
                sentimentScore: 0.8
            )

            try await addEntryUseCase.execute(entry: entry)

            let updatedStreak = try await getStreakUseCase.execute()

            if var profile = try await userRepository.fetchUserProfile() {
                profile.stats.streakCount = updatedStreak
                profile.stats.totalXP += self.earnedXP
                profile.stats.lastRitualDate = dateCreated
                try await userRepository.saveUserProfile(profile)

                logger.log(
                    "✅ Entry saved. New Streak: \(updatedStreak), XP: \(profile.stats.totalXP)"
                )
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
