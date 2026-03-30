//
//  MorningRitualView.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

public struct MorningRitualView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var viewModel: MorningRitualViewModel
    @FocusState private var isTextFieldFocused: Bool

    public init(viewModel: MorningRitualViewModel) {
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
private extension MorningRitualView {
    // Layout
    private static let coachTipBottomPadding: CGFloat = 100
    private static let scrollViewBottomSpacerHeight: CGFloat = 100
    private static let blurRadius: CGFloat = 3
    private static let phaseContainerMinHeight: CGFloat =
        MindsetLayout.iconExtraLarge + MindsetLayout.spacing24

    // Animation Timing
    private static let animationDelayShort: Double = 0.1
    private static let animationDurationBlur: Double = 0.2
    private static let animationDurationKeyboard: Double = 0.3
    private static let animationDurationNextStep: Double = 0.35
    private static let springAnimationResponse: Double = 0.35
    private static let springAnimationDamping: Double = 0.82
    private static let promptFadeInDuration: Double = 0.55
    private static let promptFadeInOffsetY: CGFloat = 10
    private static let scaleTransitionFactor: CGFloat = 0.94
    private static let placeholderExitOffset: CGFloat = -10  // Small upward offset for smooth exit
}

// MARK: - Prompt Content Phase
private extension MorningRitualView {
    enum PromptContentPhase: CaseIterable, Identifiable {
        case generating
        case `static`

        var id: Self { self }
    }

    var currentPromptContentPhase: PromptContentPhase {
        guard viewModel.currentPrompt != nil, !viewModel.isGeneratingPrompt else {
            return .generating
        }
        return .static
    }
}

// MARK: - Body Composition

private extension MorningRitualView {
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

            if #available(iOS 26.0, *) {
                lightBulbButton
                    .glassEffect(
                        .regular.interactive(),
                        in: .circle
                    )
            } else {
                // Fallback on earlier versions
                lightBulbButton
                    .buttonStyle(.automatic)
            }

            Spacer()

            if #available(iOS 26.0, *) {
                submitButtonGlass
            } else {
                // Fallback on earlier versions
                submitButtonFallBack
            }
        }
        .padding(.horizontal, MindsetLayout.paddingLarge)
        .padding(.bottom, MindsetLayout.spacing8)
        .background(.clear)
    }

    @available(iOS, deprecated: 26.0, renamed: "submitButtonGlass")
    var submitButtonFallBack: some View {
        Button(action: handleSubmit) {
            Text(SharedLocalizedString.submit)
                .font(MindsetFonts.button)
                .foregroundStyle(
                    viewModel.canProceed
                        ? MindsetColors.textOnAccent(for: colorScheme)
                        : MindsetColors.textDisabled(for: colorScheme)
                )
                .padding(.horizontal, MindsetLayout.spacing16)
                .padding(.vertical, MindsetLayout.spacing8)
                .background(
                    Capsule().fill(
                        viewModel.canProceed
                            ? MindsetColors.accentOrange
                            : MindsetColors.buttonDisabledBackground(for: colorScheme)
                    )
                )
        }
        .disabled(!viewModel.canProceed)
        .buttonStyle(.automatic)
    }

    @available(iOS 26.0, *)
    var submitButtonGlass: some View {
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
        .glassEffect(
            .regular.interactive().tint(
                viewModel.canProceed
                    ? MindsetColors.accentOrange
                    : nil
            ),
            in: .capsule
        )
    }

    private func handleSubmit() {
        HapticManager.action()
        isTextFieldFocused = false
        Task { await viewModel.submitCurrentAnswer() }
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
                VStack(spacing: MindsetLayout.spacing4) {
                    Text(prompt.category.displayName.uppercased())
                        .font(MindsetFonts.labelUppercase)
                        .tracking(1.5)
                        .foregroundStyle(MindsetColors.labelAccent(for: colorScheme))
                    if let slotLabel = viewModel.slotPositionLabel {
                        Text(slotLabel)
                            .font(MindsetFonts.caption)
                            .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    var progressBar: some View {
        MindsetProgressBar(
            backgroundFillColor: MindsetColors.dismissButtonBackground(for: colorScheme),
            progress: viewModel.progress
        )
        .padding(.horizontal)
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
                .padding(.horizontal)
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
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: MindsetLayout.spacing24) {
                ZStack(alignment: .topLeading) {
                    Group {
                        switch currentPromptContentPhase {
                        case .generating:
                            VStack(spacing: MindsetLayout.spacing16) {
                                PulsatingCoachView(emoji: "🧘‍♂️")
                                ShimmerPlaceholderView()
                                    .padding(.horizontal, MindsetLayout.paddingSmall)
                            }
                            .padding(.top, MindsetLayout.spacing12)
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                    removal: .opacity.combined(with: .scale(scale: 0.8)).combined(
                                        with: .offset(y: Self.placeholderExitOffset))
                                )
                            )

                        case .static:
                            Text(prompt.questionText)
                                .font(MindsetFonts.promptQuestion)
                                .foregroundStyle(
                                    MindsetColors.textPrimaryAdaptive(for: colorScheme)
                                )
                                .multilineTextAlignment(.leading)
                                .lineSpacing(MindsetLayout.spacing4)
                                .padding([.horizontal, .top], MindsetLayout.paddingSmall)
                                .id("\(prompt.id)-slot-\(viewModel.currentSlotIndex)")
                                .transition(
                                    .opacity.combined(with: .offset(y: Self.promptFadeInOffsetY))
                                )
                                .onAppear { viewModel.markCurrentPromptAnimated() }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .frame(minHeight: Self.phaseContainerMinHeight, alignment: .topLeading)
                .animation(
                    .easeOut(duration: Self.promptFadeInDuration),
                    value: currentPromptContentPhase
                )
                .animation(
                    .easeOut(duration: Self.promptFadeInDuration),
                    value: viewModel.currentSlotIndex
                )
                .padding(.top)

                // textEditor should be outside the Group to be always present and not part of the phase transition
                if let compositeKey = viewModel.currentCompositeAnswerKey {
                    textEditor(compositeKey: compositeKey)
                }

                if (viewModel.isAiThinking || viewModel.currentAiReflection != nil)
                    && !isTextFieldFocused
                {
                    AIReflectionCard(
                        reflection: viewModel.currentAiReflection,
                        isThinking: viewModel.isAiThinking
                    )
                    .transition(.opacity.combined(with: .offset(y: Self.promptFadeInOffsetY)))
                    .padding(.top)
                }
            }
            .animation(.easeOut(duration: Self.promptFadeInDuration), value: viewModel.isAiThinking)
            .id(viewModel.currentPromptIndex)
            .transition(stepTransition)
        }
    }

    func textEditor(compositeKey: String) -> some View {
        ZStack {
            TextEditor(
                text: Binding(
                    get: { viewModel.answers[compositeKey] ?? "" },
                    set: { viewModel.answers[compositeKey] = $0 }
                )
            )
            .frame(minHeight: MindsetLayout.textEditorMinHeight)
            .padding(MindsetLayout.paddingMedium)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusCard).fill(
                    MindsetColors.backgroundSecondary(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusCard).stroke(
                    MindsetColors.stoicSlateSoft, lineWidth: MindsetLayout.borderWidth)
            )
            .focused($isTextFieldFocused)

            if viewModel.isInterSlotTextFieldShimmering {
                RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                    .fill(MindsetColors.backgroundSecondary(for: colorScheme).opacity(0.55))
                    .shimmer()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: 0.2), value: viewModel.isInterSlotTextFieldShimmering)
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
                    .background(
                        RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                            .fill(
                                viewModel.showFooterButtonEnabledStyle
                                    ? MindsetColors.accentOrange
                                    : MindsetColors.buttonDisabledBackground(for: colorScheme)))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isFooterButtonDisabled)
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
        withAnimation(.easeInOut(duration: Self.animationDurationNextStep)) {
            viewModel.nextStep()
        }
    }
}

// MARK: - Preview

#Preview("Morning Ritual") {
    MorningRitualView(
        viewModel: MorningRitualViewModel(
            userRepository: Domain.MockUserRepository(),
            addEntryUseCase: AddEntryUseCase(
                repository: Domain.MockEntryRepository(days: 7)
            ),
            subscriptionService: Domain.MockSubscriptionService(),
            getStreakUseCase: GetStreakUseCase(repository: Domain.MockEntryRepository(days: 7)),
            aiService: Domain.MockAIService(),
            logger: DebugLogger.shared,
            onNavigate: { _ in },
            onDismiss: {}
        )
    )
}
