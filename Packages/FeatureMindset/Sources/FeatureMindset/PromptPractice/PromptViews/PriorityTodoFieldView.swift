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
            priorityIcon
            todoTextField
        }
        .padding(MindsetLayout.paddingMedium)
        .mindsetCard(radius: MindsetLayout.radiusCard)
        .accessibilityElement(children: .contain)
    }
}

private extension PriorityTodoFieldView {
    var rankBadge: some View {
        Text("\(rank)")
            .font(MindsetFonts.captionBold)
            .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
            .frame(
                width: MindsetLayout.iconButtonLarge,
                height: MindsetLayout.iconButtonLarge
            )
            .background(
                Circle().fill(MindsetColors.accentOrange)
            )
            .accessibilityLabel("Priority rank \(rank)")
    }

    var priorityIcon: some View {
        Image(systemName: priorityIconName)
            .font(MindsetFonts.bodyMedium)
            .foregroundStyle(priorityIconColor)
            .frame(
                width: MindsetLayout.iconButtonLarge,
                height: MindsetLayout.iconButtonLarge
            )
            .background(
                Circle().fill(
                    MindsetColors.dismissButtonBackground(for: colorScheme)
                )
            )
            .accessibilityLabel("\(priorityLabel) priority")
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

    var priorityIconName: String {
        switch rank {
        case 1: return "flag.fill"
        case 2: return "flag.2.crossed.fill"
        default: return "flag.3.crossed"
        }
    }

    var priorityIconColor: Color {
        switch rank {
        case 1: return MindsetColors.accentOrange
        case 2: return MindsetColors.accentBlue
        default: return MindsetColors.stoicSlate
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
