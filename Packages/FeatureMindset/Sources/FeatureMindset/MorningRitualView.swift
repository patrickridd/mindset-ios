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
        .buttonStyle(.automatic)
    }

    @available(iOS 26.0, *)
    var submitButtonGlass: some View {
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
    }

    @ViewBuilder
    var mainContentStack: some View {
        VStack(spacing: MindsetLayout.spacing12) {
            headerSection
            progressBar
            contentSection  // This contains your ScrollView
        }
        .blur(radius: viewModel.isCoachTipVisible ? 3 : 0)
        footerOverlay
        keyboardBarOverlay
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
            footerButton
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .blur(radius: viewModel.isCoachTipVisible ? 3 : 0, opaque: false)
        .animation(
            viewModel.isCoachTipVisible ? .easeIn(duration: 0.2) : .linear(duration: 0),
            value: viewModel.isCoachTipVisible
        )
    }

    var keyboardBarOverlay: some View {
        VStack {
            Spacer()
            if isTextFieldFocused {
                customKeyboardBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isTextFieldFocused)
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
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    @ViewBuilder
    var ritualContent: some View {
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: MindsetLayout.spacing24) {
                VStack(spacing: MindsetLayout.spacing16) {
                    if viewModel.shouldAnimateCurrentPrompt {
                        TypewriterText(
                            text: prompt.questionText,
                            font: MindsetFonts.promptQuestion,
                            color: MindsetColors.textPrimaryAdaptive(for: colorScheme),
                            onComplete: {
                                viewModel.markCurrentPromptAnimated()
                            }
                        )
                        .multilineTextAlignment(.leading)
                        .lineSpacing(MindsetLayout.spacing4)
                        .padding(.horizontal, MindsetLayout.paddingSmall)
                    } else {
                        Text(prompt.questionText)
                            .font(MindsetFonts.promptQuestion)
                            .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(MindsetLayout.spacing4)
                            .padding(.horizontal, MindsetLayout.paddingSmall)
                    }
                }
                .padding(.top)

                textEditor(promptId: prompt.id)

                if (viewModel.isAiThinking || viewModel.currentAiReflection != nil) && !isTextFieldFocused {
                    AIReflectionCard(
                        reflection: viewModel.currentAiReflection,
                        isThinking: viewModel.isAiThinking
                    )
                    .padding(.top)
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

    var footerButton: some View {
        VStack {
            if viewModel.shouldDisplayFooterButton {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        viewModel.nextStep()
                    }
                }) {
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
                                    : MindsetColors.buttonDisabledBackground(for: colorScheme))
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isFooterButtonDisabled)
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
