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
    @State private var viewModel: MorningRitualViewModel
    @FocusState private var isTextFieldFocused: Bool

    public init(viewModel: MorningRitualViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            backgroundView
            if viewModel.isLoading {
                initialLoadingOverlay
            } else {
                mainContentStack
                coachTipOverlay
            }
        }
    }
}

// MARK: - Body Composition

private extension MorningRitualView {
    var backgroundView: some View {
        MindsetColors.backgroundGrouped(for: colorScheme)
            .ignoresSafeArea()
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
            // Lightbulb Button
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
                        width: MindsetLayout.iconButtonLarge,
                        height: MindsetLayout.iconButtonLarge
                    )
            }

            Spacer()

            // Submit Button
            Button(action: {
                HapticManager.action()
                isTextFieldFocused = false
                Task { await viewModel.submitCurrentAnswer() }
            }) {
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
        }
        .padding(.horizontal, MindsetLayout.paddingStandard)
        .padding(.bottom, MindsetLayout.spacing4)
        .background(MindsetColors.backgroundGrouped(for: colorScheme))
    }

    @ViewBuilder
    var mainContentStack: some View {
        VStack(spacing: MindsetLayout.spacing12) {
            headerSection
            progressBar
            contentSection  // This contains your ScrollView

            if isTextFieldFocused {
                customKeyboardBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .blur(radius: viewModel.isCoachTipVisible ? 3 : 0)
        footerOverlay
    }

    var headerSection: some View {
        ZStack {
            HStack {
                Button(action: {
                    HapticManager.selection()
                    viewModel.isGoingBack = true
                    withAnimation(.easeInOut(duration: 0.35)) {
                        viewModel.previousStep()
                    }
                }) {
                    HStack(spacing: MindsetLayout.spacing8) {
                        Image(systemName: "chevron.left")
                    }
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.dismissButtonIcon(for: colorScheme))
                    .padding(.horizontal, MindsetLayout.spacing12)
                    .padding(.vertical, MindsetLayout.spacing8)
                    .background(
                        Capsule()
                            .fill(MindsetColors.backgroundSecondary(for: colorScheme))
                    )
                }
                .buttonStyle(.plain)
                .opacity(viewModel.currentStepIndex > 0 ? 1 : 0)
                .disabled(viewModel.currentStepIndex == 0)

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
        .padding(.horizontal)
    }

    var progressBar: some View {
        MindsetProgressBar(
            backgroundFillColor: MindsetColors.dismissButtonBackground(for: colorScheme),
            progress: viewModel.progress
        )
        .animation(.easeInOut(duration: 0.35), value: viewModel.isCurrentPromptSubmitted)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var contentSection: some View {
        if viewModel.isLoading {
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
                    Color.clear.frame(height: 100)
                        .id("bottom-spacer")
                }
                .padding(.horizontal)
            }
            .onChange(of: viewModel.isAiThinking) { oldValue, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation { proxy.scrollTo("bottom-spacer", anchor: .bottom) }
                    }
                } else if oldValue == true {
                    HapticManager.success()
                }
            }
            .onChange(of: viewModel.currentStepIndex) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = viewModel.shouldShowTextField
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = viewModel.shouldShowTextField
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    var footerOverlay: some View {
        VStack {
            Spacer()
            footerButtons
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .blur(radius: viewModel.isCoachTipVisible ? 3 : 0, opaque: false)
        .animation(
            viewModel.isCoachTipVisible ? .easeIn(duration: 0.2) : .linear(duration: 0),
            value: viewModel.isCoachTipVisible)
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
                        .padding(.bottom, 100)
                }
            }
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.94)).combined(
                        with: .move(edge: .bottom)),
                    removal: .opacity
                )
            )
            .animation(
                .spring(response: 0.35, dampingFraction: 0.82), value: viewModel.isCoachTipVisible)
        }
    }

    // MARK: - Subviews

    /// Transition for step content: matches OnboardingView — forward = in from trailing + opacity, back = in from leading + opacity.
    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: viewModel.isGoingBack
                ? .move(edge: .leading).combined(with: .opacity)
                : .move(edge: .trailing).combined(with: .opacity),
            removal: viewModel.isGoingBack
                ? .move(edge: .trailing).combined(with: .opacity)
                : .move(edge: .leading).combined(with: .opacity)
        )
    }

    @ViewBuilder
    var ritualContent: some View {
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: MindsetLayout.spacing24) {
                VStack(spacing: MindsetLayout.spacing16) {
                    Text(prompt.questionText)
                        .font(MindsetFonts.promptQuestion)
                        .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(MindsetLayout.spacing4)
                        .padding(.horizontal, MindsetLayout.paddingSmall)
                }
                .padding(.top)

                textEditor(promptId: prompt.id)

                if viewModel.isAiThinking || viewModel.currentAiReflection != nil {
                    AIReflectionCard(
                        reflection: viewModel.currentAiReflection,
                        isThinking: viewModel.isAiThinking
                    )
                    .padding(.top)
                }

                if !viewModel.isAiThinking && viewModel.currentAiReflection == nil {
                    Button(action: {
                        HapticManager.action()
                        Task { await viewModel.submitCurrentAnswer() }
                    }) {
                        Label(
                            FeatureMindsetStrings.MorningRitual.getAiReflection,
                            systemImage: "sparkles"
                        )
                        .font(MindsetFonts.subheadline.weight(.bold))
                        .foregroundStyle(
                            viewModel.canProceed
                                ? MindsetColors.labelAccent(for: colorScheme)
                                : MindsetColors.textDisabled(for: colorScheme)
                        )
                        .padding(.horizontal, MindsetLayout.paddingStandard)
                        .padding(.vertical, MindsetLayout.spacing10)
                        .background(
                            RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard)
                                .fill(
                                    viewModel.canProceed
                                        ? MindsetColors.accentOrangeSoft : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canProceed)
                }

                Spacer(minLength: MindsetLayout.spacerBottomMinLength)
            }
            .id(prompt.id)
            .transition(stepTransition)
        }
    }

    func textEditor(promptId: String) -> some View {
        TextEditor(
            text: Binding(
                get: { viewModel.answers[promptId] ?? "" },
                set: { viewModel.answers[promptId] = $0 }
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
    }

    var footerButtons: some View {
        VStack {
            if !viewModel.prompts.isEmpty && viewModel.isCurrentPromptSubmitted {
                let isLastStep = viewModel.currentStepIndex == viewModel.prompts.count - 1
                let checkmark: String = viewModel.canProceed ? "✅" : "☑️"
                let isDisabled =
                    !viewModel.canProceed || viewModel.isAiThinking || viewModel.isLoading
                let isAnalyzing = viewModel.isAiThinking
                let showEnabledStyle = isAnalyzing || viewModel.canProceed

                Button(action: {
                    viewModel.isGoingBack = false
                    withAnimation(.easeInOut(duration: 0.35)) {
                        viewModel.nextStep()
                    }
                }) {
                    HStack(spacing: MindsetLayout.spacing10) {
                        if isAnalyzing {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(
                            isAnalyzing
                                ? FeatureMindsetStrings.MorningRitual.analyzing
                                : (isLastStep
                                    ? "\(FeatureMindsetStrings.MorningRitual.complete) \(checkmark)"
                                    : SharedLocalizedString.continue)
                        )
                        .bold()

                        if !isLastStep && !isAnalyzing {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(
                        showEnabledStyle
                            ? MindsetColors.textOnAccent(for: colorScheme)
                            : MindsetColors.textDisabled(for: colorScheme)
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                            .fill(
                                showEnabledStyle
                                    ? MindsetColors.accentOrange
                                    : MindsetColors.buttonDisabledBackground(for: colorScheme))
                    )
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
                .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview("Morning Ritual") {
    MorningRitualView(
        viewModel: MorningRitualViewModel(
            userRepository: Domain.MockUserRepository(),
            addMindsetUseCase: AddMindsetUseCase(
                repository: Domain.MockMindsetRepository(days: 7)
            ),
            subscriptionService: Domain.MockSubscriptionService(),
            aiService: Domain.MockAIService(),
            onNavigate: { _ in },
            onDismiss: {}
        )
    )
}
