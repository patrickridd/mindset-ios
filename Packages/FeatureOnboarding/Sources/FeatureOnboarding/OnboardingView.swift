//
//  OnboardingView.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/7/26.
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

public struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    public init(viewModel: OnboardingViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body Composition

    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                mainContentStack
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isBackButtonDisplayed {
                        Button {
                            HapticManager.selection()
                            viewModel.selectedOption = nil
                            viewModel.isGoingBack = true
                            withAnimation(.easeInOut(duration: 0.35)) {
                                viewModel.goBack()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .cancel) {
                        HapticManager.selection()
                        viewModel.skipOnboarding()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private extension OnboardingView {
    var backgroundView: some View {
        LinearGradient(
            colors: [
                MindsetColors.backgroundDark,
                MindsetColors.backgroundDarkSoft,
                MindsetColors.backgroundWarmAccent.opacity(0.5),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var mainContentStack: some View {
        VStack(alignment: .center, spacing: MindsetLayout.spacing24) {
            progressSection
            if viewModel.isCalculating {
                Spacer()
                CalculatingView(onAppear: {
                    viewModel.startAnalyzingIfNeeded()
                })
                    .padding(.bottom, MindsetLayout.paddingXLarge)
                Spacer()
            } else {
                questionContent
                Spacer()
                
                skipButton
            }
            Spacer()
        }
    }

    var progressSection: some View {
        MindsetProgressBar(
            backgroundFillColor: MindsetColors.fillSubtle,
            progress: viewModel.progress,
            animationInterval: 0.35
        )
        .animation(.easeInOut(duration: 0.5), value: viewModel.isCalculating)
        .padding(.horizontal)
        .padding(.top, MindsetLayout.paddingSmall)
        .frame(maxWidth: .infinity)
    }

    var questionContent: some View {
        let question = viewModel.questions[viewModel.currentStep]
        return VStack(spacing: MindsetLayout.spacing40) {
            if viewModel.shouldAnimateCurrentQuestion {
                TypewriterText(
                    text: question.questionText,
                    font: MindsetFonts.promptHeadline,
                    color: MindsetColors.textPrimary,
                    isHapticEnabled: true,
                    onComplete: {
                        viewModel.markCurrentQuestionAnimated()
                    }
                )
                .multilineTextAlignment(.center)
                .padding()
            } else {
                Text(question.questionText)
                    .font(MindsetFonts.promptHeadline)
                    .foregroundStyle(MindsetColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            VStack(spacing: MindsetLayout.spacing12) {
                ForEach(question.options, id: \.self) { option in
                    let isSelected =
                        option == viewModel.selectedOption
                        || (viewModel.selectedOption == nil
                            && option == viewModel.selectedAnswerForCurrentStep)
                    Button {
                        HapticManager.selection()
                        viewModel.handleOptionSelected(option) {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                viewModel.selectOption(option)
                            }
                        }
                    } label: {
                        Text(option)
                            .font(MindsetFonts.bodyMedium)
                            .padding(.vertical, MindsetLayout.paddingStandard)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard)
                                    .fill(
                                        isSelected
                                            ? MindsetColors.accentOrangeSoft
                                            : MindsetColors.fillSubtle)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard)
                                    .stroke(
                                        isSelected
                                            ? MindsetColors.borderAccent
                                            : MindsetColors.borderSubtle,
                                        lineWidth: MindsetLayout.borderWidth)
                            )
                            .foregroundStyle(MindsetColors.textPrimary)
                    }
                    .buttonStyle(OptionButtonStyle())
                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedOption)
                }
            }
            .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
        }
        .id(viewModel.currentStep)
        .transition(
            .asymmetric(
                insertion: viewModel.isGoingBack
                    ? .move(edge: .leading).combined(with: .opacity)
                    : .move(edge: .trailing).combined(with: .opacity),
                removal: viewModel.isGoingBack
                    ? .move(edge: .trailing).combined(with: .opacity)
                    : .move(edge: .leading).combined(with: .opacity)
            )
        )
    }

    var skipButton: some View {
        // Continue without account (optional)
        Button {
            HapticManager.selection()
            viewModel.skipOnboarding()
        } label: {
            Text("Skip onboarding for now?")
                .font(MindsetFonts.button)
                .foregroundStyle(MindsetColors.accentBlue)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(.vertical, MindsetLayout.paddingMedium)
        }
        .disabled(viewModel.isCalculating)
    }
}

// MARK: - Option Button Style (tap feedback)

private struct OptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Calculating View (with success states and pulse)

private struct CalculatingView: View {
    @State private var isPulsing = false
    let onAppear: () -> Void

    init(onAppear: @escaping () -> Void = {}) {
        self.onAppear = onAppear
    }

    var body: some View {
        VStack(spacing: MindsetLayout.spacing30) {
            ZStack {
                Circle()
                    .fill(MindsetColors.accentOrange.opacity(0.15))
                    .frame(width: MindsetLayout.iconLarge, height: MindsetLayout.iconLarge)
                    .blur(radius: MindsetLayout.glowBlurRadius)

                ProgressView()
                    .tint(MindsetColors.accentOrange)
                    .scaleEffect(2)
            }

            Text(FeatureOnboardingStrings.Analyzing.buildingProfile)
                .font(MindsetFonts.button)
                .foregroundStyle(MindsetColors.textSecondary)

            VStack(alignment: .leading, spacing: MindsetLayout.spacing10) {
                checklistRow(FeatureOnboardingStrings.Analyzing.checklistGoals, isComplete: true)
                checklistRow(
                    FeatureOnboardingStrings.Analyzing.checklistArchetypes, isComplete: true)
                checklistRow(
                    FeatureOnboardingStrings.Analyzing.checklistYesterdayBridge, isComplete: false)
            }
            .font(MindsetFonts.caption)
        }
        .onAppear {
            onAppear()
        }
    }

    private func checklistRow(_ text: String, isComplete: Bool) -> some View {
        HStack(spacing: MindsetLayout.spacing8) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle.dotted")
                .font(MindsetFonts.callout)
                .foregroundStyle(
                    isComplete ? MindsetColors.successEmerald : MindsetColors.textMuted)

            Text(text)
                .foregroundStyle(isComplete ? MindsetColors.textSecondary : MindsetColors.textMuted)
                .opacity(isComplete ? 1 : (isPulsing ? 0.6 : 1.0))
        }
        .onAppear {
            if !isComplete {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}

#Preview {
    let logger: AppLogger = DebugLogger.shared
    let mockAuth = MockAuthService()
    let signInOrLinkUseCase = SignInOrLinkUseCase(authService: mockAuth)
    let analyzingViewModel = AnalyzingViewModel(signInOrLinkUseCase: signInOrLinkUseCase, logger: logger)
    let viewModel = OnboardingViewModel(
        userRepository: MockUserRepository(),
        signInOrLinkUseCase: signInOrLinkUseCase,
        authStateQuery: mockAuth,
        analyzingViewModel: analyzingViewModel,
        onboardingFinished: nil
    )
    return OnboardingView(viewModel: viewModel)
}
