//
//  TodayGoalsPromptQuestionView.swift
//  FeatureMindset
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

struct TodayGoalsPromptQuestionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var viewModel: MindsetPracticeFlowViewModel

    let prompt: Prompt
    let isTextFieldFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing16) {
            promptHeader
            rankedTodoFields
        }
    }
}

private extension TodayGoalsPromptQuestionView {
    var promptHeader: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing8) {
            Text(prompt.headline)
                .font(MindsetFonts.promptHeadline)
                .foregroundStyle(MindsetColors.labelAccent(for: colorScheme))

            Text(prompt.questionText)
                .font(MindsetFonts.promptQuestion)
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                .multilineTextAlignment(.leading)
                .lineSpacing(MindsetLayout.spacing4)
        }
        .padding(MindsetLayout.paddingMedium)
        .mindsetCard()
    }

    var rankedTodoFields: some View {
        VStack(spacing: MindsetLayout.spacing12) {
            // We use 0..<prompt.responseSlotCount because the slots are fixed by the prompt definition
            ForEach(0..<prompt.responseSlotCount, id: \.self) { slotIndex in
                PriorityTodoFieldView(
                    text: bindingForSlot(slotIndex),
                    rank: slotIndex + 1,
                    placeholder: placeholder(for: slotIndex),
                    isLast: slotIndex == prompt.responseSlotCount - 1,
                    isTextFieldFocused: isTextFieldFocused
                )
            }
        }
    }

    /// Clean, index-based binding into the ViewModel's answers dictionary
    func bindingForSlot(_ slotIndex: Int) -> Binding<String> {
        Binding(
            get: {
                let currentAnswers = viewModel.answers[prompt.id] ?? []
                return currentAnswers.indices.contains(slotIndex) ? currentAnswers[slotIndex] : ""
            },
            set: { newValue in
                // Ensure the array exists and is the right size
                var currentAnswers = viewModel.answers[prompt.id] ?? Array(repeating: "", count: prompt.responseSlotCount)
                if currentAnswers.indices.contains(slotIndex) {
                    currentAnswers[slotIndex] = newValue
                    viewModel.answers[prompt.id] = currentAnswers
                }
            }
        )
    }

    func placeholder(for slotIndex: Int) -> String {
        switch slotIndex {
        case 0: return "Top priority"
        case 1: return "Second priority"
        default: return "Third priority"
        }
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
    let viewModel = MindsetPracticeFlowViewModel(userRepository: MockUserRepository(), addEntryUseCase: AddEntryUseCase(entryRepository: MockEntryRepository(days: 11), userRepository: MockUserRepository()), subscriptionService: MockSubscriptionService(), getStreakUseCase: GetStreakUseCase(repository: MockEntryRepository(days: 11)), aiService: MockAIService(), logger: DebugLogger.shared, onNavigate: nil)
    
    // Seed answers so fields render with sample content
    viewModel.answers[prompt.id] = [
        "Ship v1 onboarding",
        "Triage bug backlog",
        "Plan sprint tasks"
    ]
    
    return PreviewFocusWrapper { isFocused in
        TodayGoalsPromptQuestionView(viewModel: viewModel, prompt: prompt, isTextFieldFocused: isFocused)
    }
}
