//
//  OnboardingView.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI
import Domain
import SharedUtils
import SharedUI

public struct OnboardingView: View {
#if DEBUG
    @ObserveInjection var inject
#endif

    @State private var viewModel: OnboardingViewModel

    public init(viewModel: OnboardingViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Premium gradient: charcoal → soft black with subtle warm accent
            LinearGradient(
                colors: [
                    MindsetColors.backgroundDark,
                    MindsetColors.backgroundDarkSoft,
                    MindsetColors.backgroundWarmAccent.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .center) {
                Button {
                    viewModel.dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: MindsetLayout.iconSmall, height: MindsetLayout.iconSmall)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(MindsetColors.textSecondary)
                            .padding(.trailing)
                    }
                }
                .buttonStyle(.plain)

                OnboardingProgressBar(
                    progress: viewModel.isCalculating
                        ? 1.0
                        : (viewModel.currentStep == 0 ? 0 : Double(viewModel.currentStep) / Double(viewModel.questions.count))
                )
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)
                .animation(.easeInOut(duration: 0.5), value: viewModel.isCalculating)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)

                if viewModel.isCalculating {
                    CalculatingView()
                } else {
                    questionContent
                }
                Spacer()
            }
        }
#if DEBUG
        .enableInjection()
#endif
    }

    private var questionContent: some View {
        let question = viewModel.questions[viewModel.currentStep]
        return VStack(spacing: MindsetLayout.spacing40) {
            Text(question.questionText)
                .font(MindsetFonts.displayHeadline)
                .foregroundStyle(MindsetColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding()

            VStack(spacing: MindsetLayout.spacing12) {
                ForEach(question.options, id: \.self) { option in
                    Button {
                        HapticManager.impact(.medium)
                        withAnimation(.easeInOut(duration: 0.35)) {
                            viewModel.selectOption(option)
                        }
                    } label: {
                        Text(option)
                            .font(MindsetFonts.bodyMedium)
                            .padding(.vertical, MindsetLayout.paddingStandard)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard)
                                    .fill(MindsetColors.fillSubtle)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard)
                                    .stroke(MindsetColors.borderSubtle, lineWidth: MindsetLayout.borderWidth)
                            )
                            .foregroundStyle(MindsetColors.textPrimary)
                    }
                    .buttonStyle(OptionButtonStyle())
                }
            }
            .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
        }
        .id(viewModel.currentStep)
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        )
    }
}

// MARK: - Onboarding Progress Bar (custom gradient fill)

private struct OnboardingProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: MindsetLayout.radiusSmall)
                    .fill(MindsetColors.fillSubtle)
                    .frame(height: MindsetLayout.progressBarHeight)

                RoundedRectangle(cornerRadius: MindsetLayout.radiusSmall)
                    .fill(
                        LinearGradient(
                            colors: [MindsetColors.accentCoral, MindsetColors.accentOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * progress), height: MindsetLayout.progressBarHeight)
            }
        }
        .frame(height: MindsetLayout.progressBarHeight)
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
                // Subtle glow behind spinner
                Circle()
                    .fill(MindsetColors.accentOrange.opacity(0.15))
                    .frame(width: MindsetLayout.iconLarge, height: MindsetLayout.iconLarge)
                    .blur(radius: MindsetLayout.glowBlurRadius)

                ProgressView()
                    .tint(MindsetColors.accentOrange)
                    .scaleEffect(2)
            }

            Text("Building your Identity Profile...")
                .font(MindsetFonts.button)
                .foregroundStyle(MindsetColors.textSecondary)

            VStack(alignment: .leading, spacing: MindsetLayout.spacing10) {
                checklistRow("Analyzing goals", isComplete: true)
                checklistRow("Calibrating Archetypes", isComplete: true)
                checklistRow("Setting up Yesterday Bridge", isComplete: false)
            }
            .font(MindsetFonts.caption)
        }
    }

    private func checklistRow(_ text: String, isComplete: Bool) -> some View {
        HStack(spacing: MindsetLayout.spacing8) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle.dotted")
                .font(MindsetFonts.callout)
                .foregroundStyle(isComplete ? MindsetColors.successEmerald : MindsetColors.textMuted)

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
    let viewModel = OnboardingViewModel(userRepository: MockUserRepository()) {}
    return OnboardingView(viewModel: viewModel)
}
