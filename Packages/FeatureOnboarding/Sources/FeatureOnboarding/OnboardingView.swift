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
                            .frame(width: 32, height: 32)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(MindsetColors.textSecondary)
                            .padding(.trailing)
                    }
                }
                .buttonStyle(.plain)

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
        return VStack(spacing: 40) {
            ProgressView(value: Double(viewModel.currentStep + 1), total: Double(viewModel.questions.count))
                .progressViewStyle(.linear)
                .tint(
                    LinearGradient(
                        colors: [MindsetColors.accentCoral, MindsetColors.accentOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding()

            Text(question.questionText)
                .font(MindsetFonts.displayHeadline)
                .foregroundStyle(MindsetColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding()

            VStack(spacing: 12) {
                ForEach(question.options, id: \.self) { option in
                    Button {
                        viewModel.selectOption(option)
                    } label: {
                        Text(option)
                            .font(MindsetFonts.bodyMedium)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(MindsetColors.fillSubtle)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(MindsetColors.borderSubtle, lineWidth: 1)
                            )
                            .foregroundStyle(MindsetColors.textPrimary)
                    }
                    .buttonStyle(OptionButtonStyle())
                }
            }
            .padding(.horizontal, 30)
        }
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
        VStack(spacing: 30) {
            ZStack {
                // Subtle glow behind spinner
                Circle()
                    .fill(MindsetColors.accentOrange.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)

                ProgressView()
                    .tint(MindsetColors.accentOrange)
                    .scaleEffect(2)
            }

            Text("Building your Identity Profile...")
                .font(MindsetFonts.button)
                .foregroundStyle(MindsetColors.textSecondary)

            VStack(alignment: .leading, spacing: 10) {
                checklistRow("Analyzing goals", isComplete: true)
                checklistRow("Calibrating Archetypes", isComplete: true)
                checklistRow("Setting up Yesterday Bridge", isComplete: false)
            }
            .font(MindsetFonts.caption)
        }
    }

    private func checklistRow(_ text: String, isComplete: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle.dotted")
                .font(MindsetFonts.callout)
                .foregroundStyle(isComplete ? MindsetColors.successGreen : MindsetColors.textMuted)

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
