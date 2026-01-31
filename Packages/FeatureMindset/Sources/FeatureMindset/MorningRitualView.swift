//
//  MorningRitualView.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import SharedUI
import SwiftUI

public struct MorningRitualView: View {
    @State private var viewModel: MorningRitualViewModel
    
    public init(viewModel: MorningRitualViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            // Background stays behind everything
            MindsetColors.backgroundGrouped
                .ignoresSafeArea()
            if viewModel.isLoading {
                Spacer()
                ProgressView("Designing your ritual...")
                    .tint(MindsetColors.accentOrange)
                Spacer()
            } else {
                VStack(spacing: 0) {
                    // 1. Static Progress Bar
                    ritualProgressBar
                        .padding(.vertical)
                    
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
                                VStack(spacing: 24) {
                                    ritualContent
                                    
                                    // Use a specific ID for the spacer to scroll to
                                    Color.clear.frame(height: 20)
                                        .id("bottom-spacer")
                                }
                                .padding(.horizontal)
                            }
                            .onChange(of: viewModel.isAiThinking) { _, thinking in
                                if thinking {
                                    // Delay slightly to allow keyboard/AI card to animate in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation { proxy.scrollTo("bottom-spacer", anchor: .bottom) }
                                    }
                                }
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                        // 3. Sticky Footer
                        // Removing .ignoresSafeArea from the ZStack lets the keyboard
                        // push this specific VStack up automatically.
                        footerButtons
                            .background(
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.05), radius: 5, y: -5)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    private var ritualContent: some View {
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: 24) {
                // Prompt Header
                VStack(spacing: 8) {
                    Text(prompt.category.displayName.uppercased())
                        .font(MindsetFonts.label)
                        .tracking(2)
                        .foregroundStyle(MindsetColors.labelAccent)
                    
                    Text(prompt.headline)
                        .font(MindsetFonts.promptHeadline)
                        .foregroundStyle(MindsetColors.textPrimaryAdaptive)
                }
                
                Text(prompt.questionText)
                    .font(MindsetFonts.promptQuestion)
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive)
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
                        Task { await viewModel.submitCurrentAnswer() }
                    }) {
                        Label("Get AI Reflection", systemImage: "sparkles")
                            .font(MindsetFonts.subheadline.weight(.bold))
                            .foregroundStyle(viewModel.canProceed ? MindsetColors.labelAccent : MindsetColors.textDisabled)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.canProceed ? MindsetColors.accentOrangeSoft : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canProceed)
                }

                // Coach Tip
                coachTipView(tip: prompt.coachTip)
                
                Spacer(minLength: 50)
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
        .frame(minHeight: 120)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 15).fill(MindsetColors.backgroundSecondary))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(MindsetColors.stoicSlateSoft, lineWidth: 1))
    }
    
    private func coachTipView(tip: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Coach Tip", systemImage: "lightbulb.fill")
                .font(MindsetFonts.captionBold)
                .foregroundStyle(MindsetColors.labelAccent)
            Text(tip)
                .font(MindsetFonts.caption)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(MindsetColors.accentOrangeSoft))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(MindsetColors.stoicSlateSoft, lineWidth: 1))
    }
    
    private var ritualProgressBar: some View {
        HStack {
            ForEach(0..<viewModel.prompts.count, id: \.self) { index in
                Capsule()
                    .fill(index <= viewModel.currentStepIndex ? MindsetColors.accentOrange : MindsetColors.progressInactive)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .animation(.spring(duration: 0.4, bounce: 0.3), value: viewModel.currentStepIndex)
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
                    HStack(spacing: 10) {
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
                    .foregroundStyle(showEnabledStyle ? MindsetColors.textOnAccent : MindsetColors.textDisabled)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(showEnabledStyle ? MindsetColors.accentOrange : MindsetColors.buttonDisabledBackground)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
                .padding()
            }
        }
    }
}
