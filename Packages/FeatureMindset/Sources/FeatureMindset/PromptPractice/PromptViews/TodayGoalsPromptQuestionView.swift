//
//  TodayGoalsPromptQuestionView.swift
//  FeatureMindset
//

import Domain
import SharedUI
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
            ForEach(0..<prompt.responseSlotCount, id: \.self) { slotIndex in
                PriorityTodoFieldView(
                    text: bindingForSlot(slotIndex), rank: slotIndex + 1,
                    placeholder: placeholder(for: slotIndex),
                    isLast: slotIndex == prompt.responseSlotCount - 1,
                    isTextFieldFocused: isTextFieldFocused
                )
            }
        }
    }

    func bindingForSlot(_ slotIndex: Int) -> Binding<String> {
        let compositeKey = Prompt.compositePromptId(baseId: prompt.id, slotIndex: slotIndex)
        return Binding(
            get: { viewModel.answers[compositeKey] ?? "" },
            set: { viewModel.answers[compositeKey] = $0 }
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
