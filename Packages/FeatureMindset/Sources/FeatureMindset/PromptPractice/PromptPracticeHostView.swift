//
//  PromptPracticeHostView.swift
//  FeatureMindset
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

struct PromptPracticeHostView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var viewModel: MindsetPracticeFlowViewModel
    let isTextFieldFocused: FocusState<Bool>.Binding
    private let resolver: PromptPresentationResolver

    init(
        viewModel: MindsetPracticeFlowViewModel,
        isTextFieldFocused: FocusState<Bool>.Binding,
        resolver: PromptPresentationResolver = .init()
    ) {
        self.viewModel = viewModel
        self.isTextFieldFocused = isTextFieldFocused
        self.resolver = resolver
    }

    var body: some View {
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: MindsetLayout.spacing24) {
                promptPhaseView(for: prompt)

                // Input field for standard (sequential) prompts
                if shouldShowLegacyTextEditor {
                    standardTextEditor(for: prompt)
                }

                if (viewModel.isAiThinking || viewModel.currentAiReflection != nil)
                    && !isTextFieldFocused.wrappedValue
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
        }
    }
}

private extension PromptPracticeHostView {
    enum PromptContentPhase: CaseIterable, Identifiable {
        case generating
        case `static`

        var id: Self { self }
    }

    static let phaseContainerMinHeight: CGFloat = MindsetLayout.iconExtraLarge + MindsetLayout.spacing24
    static let promptFadeInDuration: Double = 0.55
    static let promptFadeInOffsetY: CGFloat = 10
    static let placeholderExitOffset: CGFloat = -10

    var currentPromptContentPhase: PromptContentPhase {
        guard viewModel.currentPrompt != nil, !viewModel.isGeneratingPrompt else {
            return .generating
        }
        return .static
    }

    var activePresentationKind: PromptPresentationKind? {
        guard let prompt = viewModel.currentPrompt else { return nil }
        return resolver.presentationKind(for: prompt)
    }

    var shouldShowLegacyTextEditor: Bool {
        activePresentationKind != .todayGoals
//        && activePresentationKind != .multiSlotInput
    }
    
    @ViewBuilder
    func promptPhaseView(for prompt: Prompt) -> some View {
        ZStack(alignment: .topLeading) {
            switch currentPromptContentPhase {
            case .generating:
                generationPlaceholder
            case .static:
                promptQuestionView(for: prompt)
                // Use a clean ID for transitions when slots change
                    .id("\(prompt.id)-slot-\(viewModel.currentSlotIndex)")
                    .transition(.opacity.combined(with: .offset(y: Self.promptFadeInOffsetY)))
                    .onAppear { viewModel.markCurrentPromptAnimated() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: Self.phaseContainerMinHeight, alignment: .topLeading)
        .animation(.easeOut(duration: Self.promptFadeInDuration), value: currentPromptContentPhase)
        .animation(.easeOut(duration: Self.promptFadeInDuration), value: viewModel.currentSlotIndex)
        .padding(.top)
    }

    @ViewBuilder
    func promptQuestionView(for prompt: Prompt) -> some View {
        switch resolver.presentationKind(for: prompt) {
        case .defaultTextEntry:
            DefaultPromptQuestionView(prompt: prompt)
        case .guidedVisualization:
            GuidedVisualizationPromptQuestionView(prompt: prompt)
        case .todayGoals:
            TodayGoalsPromptQuestionView(viewModel: viewModel, prompt: prompt, isTextFieldFocused: isTextFieldFocused)
        case .multiSlotInput:
            MultiSlotPromptQuestionView(viewModel: viewModel, prompt: prompt, isTextFieldFocused: isTextFieldFocused)
        }
    }

    /// The input field for prompts that aren't using a custom multi-field layout
    @ViewBuilder
    func standardTextEditor(for prompt: Prompt) -> some View {
        ZStack {
            TextEditor(text: $viewModel.currentInputText) // Using the new computed property!
                .frame(minHeight: MindsetLayout.textEditorMinHeight)
                .padding(MindsetLayout.paddingMedium)
                .background(
                    RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                        .fill(MindsetColors.backgroundSecondary(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                        .stroke(MindsetColors.stoicSlateSoft, lineWidth: MindsetLayout.borderWidth)
                )
                .focused(isTextFieldFocused)
            
            // 3. Invisible TextField to capture hardware/software keyboard input
            TextField("", text: $viewModel.currentInputText)
                .focused(isTextFieldFocused)
                .opacity(0)
                .frame(height: 0)
        }
    }

    // MARK: - Subviews & Helpers
    
    var generationPlaceholder: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            PulsatingCoachView(emoji: "✨")
            ShimmerPlaceholderView()
                .padding(.horizontal, MindsetLayout.paddingSmall)
        }
        .padding(.top, MindsetLayout.spacing12)
        .transition(generatingTransition)
    }
    
    var shimmerOverlay: some View {
        RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
            .fill(MindsetColors.backgroundSecondary(for: colorScheme).opacity(0.55))
            .shimmer()
            .allowsHitTesting(false)
            .transition(.opacity)
    }

    private var generatingTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity
                .combined(with: .scale(scale: 0.8))
                .combined(with: .offset(y: Self.placeholderExitOffset))
        )
    }
}

private struct PreviewFocusWrapper<Content: View>: View {
      @FocusState private var isFocused: Bool
      let content: (FocusState<Bool>.Binding) -> Content

      init(@ViewBuilder content: @escaping (FocusState<Bool>.Binding) -> Content) {
          self.content = content
      }

      var body: some View {
          content($isFocused)
      }
  }

#Preview {
    // Stub prompt matching what the view expects
    let prompt = MindsetPrompt.todoToday
    
    // Minimal view model setup for preview
    let viewModel = MindsetPracticeFlowViewModel(userRepository: MockUserRepository(), addEntryUseCase: AddEntryUseCase(repository: MockEntryRepository(days: 11)), subscriptionService: MockSubscriptionService(), getStreakUseCase: GetStreakUseCase(repository: MockEntryRepository(days: 11)), aiService: MockAIService(), logger: DebugLogger.shared, onNavigate: nil)
    
    // Seed answers so fields render with sample content
    viewModel.answers[prompt.id] = [
        "Ship v1 onboarding",
        "Triage bug backlog",
        "Plan sprint tasks"
    ]
    
    return PreviewFocusWrapper { isFocused in
        PromptPracticeHostView(viewModel: viewModel, isTextFieldFocused: isFocused)
    }
}
