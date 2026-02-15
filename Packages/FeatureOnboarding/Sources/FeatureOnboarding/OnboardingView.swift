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
    #if DEBUG
        @ObserveInjection var inject
    #endif

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
                        viewModel.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        #if DEBUG
            .enableInjection()
        #endif
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
                CalculatingView()
                    .padding(.bottom, MindsetLayout.paddingXLarge)
                Spacer()
            } else {
                questionContent
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
                        viewModel.selectedOption = option
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            viewModel.isGoingBack = false
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    viewModel.selectOption(option)
                                }
                                viewModel.selectedOption = nil
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
    let viewModel = OnboardingViewModel(
        userRepository: MockUserRepository(),
        onboardingFinished: nil
    )
    return OnboardingView(viewModel: viewModel)
}
