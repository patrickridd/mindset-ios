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
    @FocusState private var isTextFieldFocused: Bool
    
    public init(viewModel: MorningRitualViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            // Background stays behind everything
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Designing your ritual...")
                        .tint(MindsetColors.accentOrange)
                    Spacer()
                }
            } else {
                // Main content layer
                VStack(spacing: MindsetLayout.spacing12) {
                    // Header with back and dismiss buttons
                    ZStack {
                        // Background layer: buttons on leading and trailing
                        HStack {
                            // Back button - always reserve space, fade in/out
                            Button(action: {
                                HapticManager.selection()
                                withAnimation(.spring()) {
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
                        
                        // Foreground layer: centered category label
                        if let prompt = viewModel.currentPrompt {
                            Text(prompt.category.displayName.uppercased())
                                .font(MindsetFonts.labelUppercase)
                                .tracking(1.5)
                                .foregroundStyle(MindsetColors.labelAccent(for: colorScheme))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Progress Bar
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
                                    
                                    // Extra padding at bottom to account for fixed footer
                                    Color.clear.frame(height: 100)
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
                            .onChange(of: viewModel.currentStepIndex) { _, _ in
                                // Focus keyboard when moving to next prompt
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isTextFieldFocused = true
                                }
                            }
                            .onAppear {
                                // Auto-focus keyboard when ritual starts
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isTextFieldFocused = true
                                }
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                }
                .blur(radius: viewModel.isCoachTipVisible ? 3 : 0, opaque: false)
                .animation(viewModel.isCoachTipVisible ? .easeIn(duration: 0.2) : .linear(duration: 0.2), value: viewModel.isCoachTipVisible)
                
                // Footer overlay - stays at bottom behind keyboard
                VStack {
                    Spacer()
                    footerButtons
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .blur(radius: viewModel.isCoachTipVisible ? 3 : 0, opaque: false)
                .animation(viewModel.isCoachTipVisible ? .easeIn(duration: 0.2) : .linear(duration: 0), value: viewModel.isCoachTipVisible)
            }
            
            // Custom coach tip overlay — above keyboard; tap outside to dismiss
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
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.94)).combined(with: .move(edge: .bottom)),
                    removal: .opacity
                ))
                .animation(.spring(response: 0.35, dampingFraction: 0.82), value: viewModel.isCoachTipVisible)
            }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    private var ritualContent: some View {
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: MindsetLayout.spacing24) {
                // Simplified Prompt Display
                VStack(spacing: MindsetLayout.spacing16) {
                    // Main question - clear and prominent
                    Text(prompt.questionText)
                        .font(MindsetFonts.promptQuestion)
                        .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(MindsetLayout.spacing4)
                        .padding(.horizontal, MindsetLayout.paddingSmall)
                }
                .padding(.top)
                
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
        .focused($isTextFieldFocused)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                // Coach tip button — 44pt min tap target (Apple HIG)
                Button {
                    HapticManager.selection()
                    viewModel.toggleCoachTip()
                } label: {
                    Image(systemName: viewModel.isCoachTipVisible ? "lightbulb.fill" : "lightbulb")
                        .font(MindsetFonts.body)
                        .foregroundStyle(viewModel.isCoachTipVisible ? MindsetColors.labelAccent(for: colorScheme) : MindsetColors.textSecondaryAdaptive(for: colorScheme))
                        .contentTransition(.symbolEffect(.replace))
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Submit button — fits content; min height for tap target
                Button(action: {
                    HapticManager.action()
                    isTextFieldFocused = false // Dismiss keyboard
                    Task { await viewModel.submitCurrentAnswer() }
                }) {
                    Text("Submit")
                        .font(MindsetFonts.button)
                        .foregroundStyle(viewModel.canProceed ? MindsetColors.textOnAccent(for: colorScheme) : MindsetColors.textDisabled(for: colorScheme))
                        .padding(.horizontal, MindsetLayout.spacing16)
                        .padding(.vertical, MindsetLayout.spacing8)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                        .background(
                            Capsule()
                                .fill(viewModel.canProceed ? MindsetColors.accentOrange : MindsetColors.buttonDisabledBackground(for: colorScheme))
                        )
                }
                .buttonStyle(.plain)
                .fixedSize(horizontal: true, vertical: false)
                .disabled(!viewModel.canProceed)
            }
        }
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

// MARK: - Coach Tip Popover Component

struct CoachTipPopover: View {
    @Environment(\.colorScheme) private var colorScheme
    let tip: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            HStack(spacing: MindsetLayout.spacing8) {
                Image(systemName: "lightbulb.fill")
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.accentOrange)
                
                Text("Coach Tip")
                    .font(MindsetFonts.label.weight(.semibold))
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
            }
            
            Text(tip)
                .font(MindsetFonts.callout)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .multilineTextAlignment(.leading)
        }
        .padding(MindsetLayout.paddingStandard)
        .frame(maxWidth: 340, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                .fill(MindsetColors.backgroundSecondary(for: colorScheme))
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                .strokeBorder(MindsetColors.borderSubtle.opacity(0.3), lineWidth: 1)
        )
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
            onDismiss: { }
        )
    )
}
