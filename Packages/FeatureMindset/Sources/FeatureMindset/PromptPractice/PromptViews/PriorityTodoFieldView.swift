//
//  PriorityTodoFieldView.swift
//  FeatureMindset
//

import SharedUI
import SwiftUI

struct PriorityTodoFieldView: View {

    @Environment(\.colorScheme) private var colorScheme
    @Binding var text: String

    let rank: Int
    let placeholder: String
    let isLast: Bool
    let isTextFieldFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(alignment: .center, spacing: MindsetLayout.spacing12) {
            rankBadge
            todoTextField
        }
        .padding(MindsetLayout.paddingMedium)
        .mindsetCard(radius: MindsetLayout.radiusCard)
        .accessibilityElement(children: .contain)
    }
}

private extension PriorityTodoFieldView {
    var rankBadge: some View {
        Text(priority(rank: rank))
            .font(.largeTitle)
            .frame(
                width: MindsetLayout.iconButtonLarge,
                height: MindsetLayout.iconButtonLarge
            )
            .accessibilityLabel("Priority rank \(rank)")
    }

    var todoTextField: some View {
        TextField(placeholder, text: $text)
            .font(MindsetFonts.body)
            .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
            .textInputAutocapitalization(.sentences)
            .submitLabel(isLast ? .done : .next)
            .focused(isTextFieldFocused)
            .accessibilityLabel("\(priorityLabel) todo")
            .accessibilityHint("Enter your \(priorityLabel.lowercased()) priority task for today")
    }

    func priority(rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    var priorityLabel: String {
        switch rank {
        case 1: return "Highest"
        case 2: return "Medium"
        default: return "Lower"
        }
    }
}

#Preview {
    struct PriorityTodoFieldView_PreviewContainer: View {
        @State private var text: String = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            PriorityTodoFieldView(
                text: $text,
                rank: 1,
                placeholder: "Number 1 spot",
                isLast: false,
                isTextFieldFocused: $isFocused
            )
        }
    }

    return PriorityTodoFieldView_PreviewContainer()
}
