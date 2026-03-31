//
//  PromptPracticeHostView.swift
//  FeatureMindset
//

import Domain
import SharedUI
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

                // Keep input outside phase animation so typing state remains stable.
                if shouldShowLegacyTextEditor, let compositeKey = viewModel.currentCompositeAnswerKey {
                    textEditor(compositeKey: compositeKey)
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
    }

    @ViewBuilder
    func promptPhaseView(for prompt: Prompt) -> some View {
        ZStack(alignment: .topLeading) {
            Group {
                switch currentPromptContentPhase {
                case .generating:
                    VStack(spacing: MindsetLayout.spacing16) {
                        PulsatingCoachView(emoji: "🧘‍♂️")
                        ShimmerPlaceholderView()
                            .padding(.horizontal, MindsetLayout.paddingSmall)
                    }
                    .padding(.top, MindsetLayout.spacing12)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 0.8)).combined(
                                with: .offset(y: Self.placeholderExitOffset))
                        )
                    )

                case .static:
                    promptQuestionView(for: prompt)
                        .id("\(prompt.id)-slot-\(viewModel.currentSlotIndex)")
                        .transition(.opacity.combined(with: .offset(y: Self.promptFadeInOffsetY)))
                        .onAppear { viewModel.markCurrentPromptAnimated() }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: Self.phaseContainerMinHeight, alignment: .topLeading)
        .animation(
            .easeOut(duration: Self.promptFadeInDuration),
            value: currentPromptContentPhase
        )
        .animation(
            .easeOut(duration: Self.promptFadeInDuration),
            value: viewModel.currentSlotIndex
        )
        .padding(.top)
    }

    @ViewBuilder
    func promptQuestionView(for prompt: Prompt) -> some View {
        switch resolver.presentationKind(for: prompt) {
        case .defaultTextEntry:
            DefaultPromptQuestionView(prompt: prompt, colorScheme: colorScheme)
        case .guidedVisualization:
            GuidedVisualizationPromptQuestionView(prompt: prompt, colorScheme: colorScheme)
        case .todayGoals:
            TodayGoalsPromptQuestionView(
                prompt: prompt,
                viewModel: viewModel,
                isTextFieldFocused: isTextFieldFocused
            )
        }
    }

    func textEditor(compositeKey: String) -> some View {
        ZStack {
            TextEditor(
                text: Binding(
                    get: { viewModel.answers[compositeKey] ?? "" },
                    set: { viewModel.answers[compositeKey] = $0 }
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
            .focused(isTextFieldFocused)

            if viewModel.isInterSlotTextFieldShimmering {
                RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                    .fill(MindsetColors.backgroundSecondary(for: colorScheme).opacity(0.55))
                    .shimmer()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: 0.2), value: viewModel.isInterSlotTextFieldShimmering)
    }
}
