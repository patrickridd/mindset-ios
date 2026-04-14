//
//  MindsetPracticeFlowView.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

public struct MindsetPracticeFlowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var viewModel: MindsetPracticeFlowViewModel
    @FocusState private var isTextFieldFocused: Bool

    public init(viewModel: MindsetPracticeFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            backgroundView
            mainContentOrLoading
            coachTipOverlay
        }
        .animation(
            .spring(
                response: Self.springAnimationResponse,
                dampingFraction: Self.springAnimationDamping),
            value: viewModel.isCoachTipVisible
        )
    }
}

// MARK: - Constants
private extension MindsetPracticeFlowView {
    // Layout
    private static let coachTipBottomPadding: CGFloat = 100
    private static let scrollViewBottomSpacerHeight: CGFloat = 100
    private static let blurRadius: CGFloat = 3

    // Animation Timing
    private static let animationDelayShort: Double = 0.1
    private static let animationDurationBlur: Double = 0.2
    private static let animationDurationKeyboard: Double = 0.3
    private static let animationDurationNextStep: Double = 0.35
    private static let springAnimationResponse: Double = 0.35
    private static let springAnimationDamping: Double = 0.82
    private static let scaleTransitionFactor: CGFloat = 0.94
}

// MARK: - Body Composition

private extension MindsetPracticeFlowView {
    var backgroundView: some View {
        MindsetColors.backgroundGrouped(for: colorScheme)
            .ignoresSafeArea()
    }

    @ViewBuilder
    var mainContentOrLoading: some View {
        if (viewModel.isLoading && viewModel.prompts.isEmpty)
            || viewModel.isRitualCompleteAnimationDone
        {
            initialLoadingOverlay
        } else if viewModel.displayRitualSuccessAnimation {
            MindsetAnimationView(animation: .checkmarkSuccess, loopMode: .playOnce) {
                // This triggers automatically when the .lottie file ends
                withAnimation(.easeInOut(duration: 0.5)) {
                    viewModel.isRitualCompleteAnimationDone = true
                    viewModel.completeRitual()
                }
            }

            MindsetAnimationView(animation: .confetti, loopMode: .playOnce)
        } else {
            mainContentStack
        }
    }

    var initialLoadingOverlay: some View {
        VStack {
            Spacer()
            ProgressView(viewModel.loadingDescription)
                .tint(MindsetColors.accentOrange)
            Spacer()
        }
    }

    private var customKeyboardBar: some View {
        HStack(alignment: .center) {
            lightBulbButton

            Spacer()

            submitButton
        }
        .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
        .padding(.bottom, MindsetLayout.spacing8)
        .background(.clear)
    }

    var submitButton: some View {
        Button(action: handleSubmit) {
            Text(SharedLocalizedString.submit)
                .font(MindsetFonts.button)
                .foregroundStyle(
                    viewModel.canProceed
                        ? MindsetColors.textOnAccent(for: colorScheme)
                        : MindsetColors.textDisabled(for: colorScheme)
                )
                .padding(.horizontal, MindsetLayout.spacing20)
                .padding(.vertical, MindsetLayout.spacing12)
        }
        .disabled(!viewModel.canProceed)
        .mindsetButton(
            color: viewModel.canProceed
                ? MindsetColors.accentOrange
                : MindsetColors.buttonDisabledBackground(for: colorScheme),
            radius: MindsetLayout.radiusButton
        )
    }

    private func handleSubmit() {
        // Light tap for each item, Success tap for the final ritual completion
        if viewModel.currentSlotIndex < (viewModel.currentPrompt?.responseSlotCount ?? 1) - 1 {
            HapticManager.impact(.light)
        } else {
            HapticManager.success() // Dopamine spike for finishing the set!
        }
        
        if shouldDismissKeyboardOnSubmit {
            isTextFieldFocused = false
        }
        Task { await viewModel.submitCurrentAnswer() }
    }

    var shouldDismissKeyboardOnSubmit: Bool {
        guard let prompt = viewModel.currentPrompt else { return true }
        if prompt.id == MindsetPrompt.todoToday.id {
            return true
        }
        return viewModel.currentSlotIndex >= prompt.responseSlotCount - 1
    }

    var lightBulbButton: some View {
        Button {
            HapticManager.selection()
            viewModel.toggleCoachTip()
        } label: {
            Image(systemName: viewModel.isCoachTipVisible ? "lightbulb.fill" : "lightbulb")
                .font(MindsetFonts.body)
                .foregroundStyle(
                    viewModel.isCoachTipVisible
                        ? MindsetColors.labelAccent(for: colorScheme)
                        : MindsetColors.textSecondaryAdaptive(for: colorScheme)
                )
                .frame(
                    width: MindsetLayout.iconButtonLarge + 2,
                    height: MindsetLayout.iconButtonLarge + 2
                )
        }
        .mindsetButton(
            color: viewModel.isCoachTipVisible
                ? MindsetColors.accentOrange
                : MindsetColors.dismissButtonBackground(for: colorScheme),
            radius: (MindsetLayout.iconButtonLarge + 2) / 2
        )
        .accessibilityLabel(viewModel.isCoachTipVisible ? "Hide coach tip" : "Show coach tip")
        .accessibilityHint("Toggles visibility of the coach tip for the current prompt")
    }

    @ViewBuilder
    var mainContentStack: some View {
        ZStack {
            VStack(spacing: MindsetLayout.spacing12) {
                headerSection
                progressBar
                contentSection  // This contains your ScrollView
            }
            .blur(radius: viewModel.isCoachTipVisible ? Self.blurRadius : 0)

            footerOverlay
            keyboardBarOverlay
        }
    }

    var headerSection: some View {
        ZStack {
            HStack {
                Spacer()

                DismissButton(action: { viewModel.dismiss() })
            }

            if let prompt = viewModel.currentPrompt {
                Text(prompt.category.displayName.uppercased())
                    .font(MindsetFonts.labelUppercase)
                    .tracking(1.5)
                    .foregroundStyle(MindsetColors.labelAccent(for: colorScheme))
            }
        }
        .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
    }

    var progressBar: some View {
        MindsetProgressBar(
            backgroundFillColor: MindsetColors.dismissButtonBackground(for: colorScheme),
            progress: viewModel.progress
        )
        .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var contentSection: some View {
        if viewModel.isLoading && viewModel.prompts.isEmpty {
            VStack {
                Spacer()
                ProgressView(FeatureMindsetStrings.MorningRitual.fetchingPrompts)
                Spacer()
            }
        } else if viewModel.prompts.isEmpty {
            VStack {
                Spacer()
                ContentUnavailableView(
                    FeatureMindsetStrings.MorningRitual.noPromptsFound,
                    systemImage: "exclamationmark.triangle",
                    description: Text(FeatureMindsetStrings.MorningRitual.noPromptsFoundDescription)
                )
                Spacer()
            }
        } else {
            ritualScrollView
        }
    }

    var ritualScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: MindsetLayout.spacing24) {
                    ritualContent
                    Color.clear.frame(height: Self.scrollViewBottomSpacerHeight)
                        .id("bottom-spacer")
                }
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
            }
            .onChange(of: viewModel.isAiThinking) { oldValue, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Self.animationDelayShort) {
                        withAnimation { proxy.scrollTo("bottom-spacer", anchor: .bottom) }
                    }
                } else if oldValue == true {
                    HapticManager.success()
                }
            }
            .onChange(of: viewModel.currentPromptIndex) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.animationDelayShort) {
                    isTextFieldFocused = viewModel.shouldShowTextField
                }
            }
            .onChange(of: viewModel.currentSlotIndex) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.animationDelayShort) {
                    isTextFieldFocused = viewModel.shouldShowTextField
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.animationDelayShort) {
                    isTextFieldFocused = viewModel.shouldShowTextField
                }
            }
        }
        .scrollDismissesKeyboard(.never)
    }

    var footerOverlay: some View {
        VStack {
            Spacer()
            footerButton
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .blur(radius: viewModel.isCoachTipVisible ? Self.blurRadius : 0, opaque: false)
        .animation(
            .easeIn(duration: Self.animationDurationBlur), value: viewModel.isCoachTipVisible)
    }

    var keyboardBarOverlay: some View {
        VStack {
            Spacer()
            if isTextFieldFocused {
                customKeyboardBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: Self.animationDurationKeyboard), value: isTextFieldFocused)
    }

    @ViewBuilder
    var coachTipOverlay: some View {
        if viewModel.isCoachTipVisible, let prompt = viewModel.currentPrompt {
            Group {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.toggleCoachTip()
                    }
                VStack {
                    Spacer()
                    CoachTipPopover(tip: prompt.coachTip)
                        .padding(.horizontal, MindsetLayout.paddingStandard)
                        .padding(.bottom, Self.coachTipBottomPadding)
                }
            }
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: Self.scaleTransitionFactor))
                        .combined(
                            with: .move(edge: .bottom)),
                    removal: .opacity
                )
            )
        }
    }

    // MARK: - Subviews

    /// Transition for step content: matches OnboardingView — forward = in from trailing + opacity, back = in from leading + opacity.
    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    @ViewBuilder
    var ritualContent: some View {
        if viewModel.currentPrompt != nil {
            PromptPracticeHostView(
                viewModel: viewModel,
                isTextFieldFocused: $isTextFieldFocused
            )
            .id(viewModel.currentPromptIndex)
            .transition(stepTransition)
        }
    }

    var footerButton: some View {
        VStack {
            if viewModel.shouldDisplayFooterButton {
                Button(action: handleNextStep) {
                    HStack(spacing: MindsetLayout.spacing10) {
                        if viewModel.isAiThinking {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(viewModel.footerButtonText)
                            .bold()

                        if !viewModel.isLastStep && !viewModel.isAiThinking {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(
                        viewModel.showFooterButtonEnabledStyle
                            ? MindsetColors.textOnAccent(for: colorScheme)
                            : MindsetColors.textDisabled(for: colorScheme)
                    )
                    .padding()
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isFooterButtonDisabled)
                .mindsetButton(
                    color: viewModel.showFooterButtonEnabledStyle
                        ? MindsetColors.accentOrange
                        : MindsetColors.buttonDisabledBackground(for: colorScheme),
                    radius: MindsetLayout.radiusButton
                )
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(
            .spring(
                response: Self.springAnimationResponse,
                dampingFraction: Self.springAnimationDamping),
            value: viewModel.shouldDisplayFooterButton
        )
    }

    private func handleNextStep() {
        isTextFieldFocused = false
        withAnimation(.easeInOut(duration: Self.animationDurationNextStep)) {
            viewModel.nextStep()
        }
    }
}

// MARK: - Preview

#Preview("Morning Ritual") {
    let entryRepo = MockEntryRepository(days: 11)
    return MindsetPracticeFlowView(
        viewModel: MindsetPracticeFlowViewModel(
            ritualType: .morning,
            userRepository: MockUserRepository(),
            entryRepository: entryRepo,
            addEntryUseCase: AddEntryUseCase(entryRepository: entryRepo, statsRepository: MockUserStatsRepository()),
            subscriptionService: MockSubscriptionService(),
            getStreakUseCase: GetStreakUseCase(repository: entryRepo),
            ritualGenerator: MockRitualGenerator(),
            aiService: MockAIService(),
            logger: DebugLogger.shared,
            onNavigate: nil
        )
    )
}
