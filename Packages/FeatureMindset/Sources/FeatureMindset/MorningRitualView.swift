//
//  MorningRitualView.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

public struct MorningRitualView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: MorningRitualViewModel
    
    public init(viewModel: MorningRitualViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            // Background stays behind everything
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()
            if viewModel.isLoading {
                Spacer()
                ProgressView("Designing your ritual...")
                    .tint(MindsetColors.accentOrange)
                Spacer()
            } else {
                VStack(spacing: MindsetLayout.spacing12) {
                    DismissButton(action: { viewModel.dismiss() })

                    // 1. Progress Bar (shared MindsetProgressBar)
                    MindsetProgressBar(
                        progress: viewModel.prompts.isEmpty
                            ? 0
                            : Double(viewModel.currentStepIndex + 1) / Double(viewModel.prompts.count)
                    )
                    .animation(.easeInOut(duration: 0.35), value: viewModel.currentStepIndex)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Fetching your prompts...")
                        Spacer()
                    } else if viewModel.prompts.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "No Prompts Found",
                            systemImage: "exclamationmark.triangle",
                            description: Text("Try restarting the ritual or check your profile settings.")
                        )
                        Spacer()
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: MindsetLayout.spacing24) {
                                    ritualContent
                                    
                                    // Use a specific ID for the spacer to scroll to
                                    Color.clear.frame(height: MindsetLayout.bottomSpacerHeight)
                                        .id("bottom-spacer")
                                }
                                .padding(.horizontal)
                            }
                            .onChange(of: viewModel.isAiThinking) { oldValue, newValue in
                                if newValue {
                                    // Delay slightly to allow keyboard/AI card to animate in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation { proxy.scrollTo("bottom-spacer", anchor: .bottom) }
                                    }
                                } else if oldValue == true {
                                    HapticManager.success()
                                }
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                        // 3. Sticky Footer
                        // Removing .ignoresSafeArea from the ZStack lets the keyboard
                        // push this specific VStack up automatically.
                        footerButtons
                    }
                }
            }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    private var ritualContent: some View {
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: MindsetLayout.spacing24) {
                // Prompt Header
                VStack(spacing: MindsetLayout.spacing8) {
                    Text(prompt.category.displayName.uppercased())
                        .font(MindsetFonts.label)
                        .tracking(2)
                        .foregroundStyle(MindsetColors.labelAccent(for: colorScheme))
                    
                    Text(prompt.headline)
                        .font(MindsetFonts.promptHeadline)
                        .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                }
                
                Text(prompt.questionText)
                    .font(MindsetFonts.promptQuestion)
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Input Area
                textEditor(promptId: prompt.id)
                
                // AI Section (Pulls from currentAiReflection computed property)
                if viewModel.isAiThinking || viewModel.currentAiReflection != nil {
                    AIReflectionCard(
                        reflection: viewModel.currentAiReflection,
                        isThinking: viewModel.isAiThinking
                    )
                    .padding(.top)
                }
                
                // Feedback Trigger
                if !viewModel.isAiThinking && viewModel.currentAiReflection == nil {
                    Button(action: {
                        HapticManager.action()
                        Task { await viewModel.submitCurrentAnswer() }
                    }) {
                        Label("Get AI Reflection", systemImage: "sparkles")
                            .font(MindsetFonts.subheadline.weight(.bold))
                            .foregroundStyle(viewModel.canProceed ? MindsetColors.labelAccent(for: colorScheme) : MindsetColors.textDisabled(for: colorScheme))
                            .padding(.horizontal, MindsetLayout.paddingStandard)
                            .padding(.vertical, MindsetLayout.spacing10)
                            .background(
                                RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard)
                                    .fill(viewModel.canProceed ? MindsetColors.accentOrangeSoft : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canProceed)
                }

                // Coach Tip
                coachTipView(tip: prompt.coachTip)
                
                Spacer(minLength: MindsetLayout.spacerBottomMinLength)
            }
            // Transition for "Duolingo" slide effect
            .id(prompt.id)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }

    private func textEditor(promptId: String) -> some View {
        TextEditor(text: Binding(
            get: { viewModel.answers[promptId] ?? "" },
            set: { viewModel.answers[promptId] = $0 }
        ))
        // Fixed height prevents the "shrinking" issue when keyboard appears
        .frame(minHeight: MindsetLayout.textEditorMinHeight)
        .padding(MindsetLayout.paddingMedium)
        .background(RoundedRectangle(cornerRadius: MindsetLayout.radiusCard).fill(MindsetColors.backgroundSecondary(for: colorScheme)))
        .overlay(RoundedRectangle(cornerRadius: MindsetLayout.radiusCard).stroke(MindsetColors.stoicSlateSoft, lineWidth: MindsetLayout.borderWidth))
    }
    
    private func coachTipView(tip: String) -> some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing5) {
            Label("Coach Tip", systemImage: "lightbulb.fill")
                .font(MindsetFonts.captionBold)
                .foregroundStyle(MindsetColors.labelAccent(for: colorScheme))
            Text(tip)
                .font(MindsetFonts.caption)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard).fill(MindsetColors.accentOrangeSoft))
        .overlay(RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard).stroke(MindsetColors.stoicSlateSoft, lineWidth: MindsetLayout.borderWidth))
    }
    
    private var footerButtons: some View {
        VStack {
            // Guard against empty prompts to avoid index out of bounds
            if !viewModel.prompts.isEmpty {
                let isLastStep = viewModel.currentStepIndex == viewModel.prompts.count - 1
                let checkmark: String = viewModel.canProceed ? "✅" : "☑️"
                let isDisabled = !viewModel.canProceed || viewModel.isAiThinking || viewModel.isLoading
                let isAnalyzing = viewModel.isAiThinking
                let showEnabledStyle = isAnalyzing || viewModel.canProceed

                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.nextStep()
                    }
                }) {
                    HStack(spacing: MindsetLayout.spacing10) {
                        if isAnalyzing {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(isAnalyzing ? "Analyzing..." : (isLastStep ? "Complete \(checkmark)" : "Continue"))
                            .bold()

                        if !isLastStep && !isAnalyzing {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(showEnabledStyle ? MindsetColors.textOnAccent(for: colorScheme) : MindsetColors.textDisabled(for: colorScheme))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                            .fill(showEnabledStyle ? MindsetColors.accentOrange : MindsetColors.buttonDisabledBackground(for: colorScheme))
                    )
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
                .padding()
            }
        }
    }
}
