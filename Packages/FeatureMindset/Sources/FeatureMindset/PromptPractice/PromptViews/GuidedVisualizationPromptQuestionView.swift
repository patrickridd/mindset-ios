//
//  GuidedVisualizationPromptQuestionView.swift
//  FeatureMindset
//

import Domain
import SharedUI
import SwiftUI

struct GuidedVisualizationPromptQuestionView: View {
    let prompt: Prompt
    let colorScheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(prompt.headline)
                .font(MindsetFonts.labelUppercase)
                .tracking(1.2)
                .foregroundStyle(MindsetColors.labelAccent(for: colorScheme))

            Text(prompt.questionText)
                .font(MindsetFonts.promptQuestion)
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                .multilineTextAlignment(.leading)
                .lineSpacing(MindsetLayout.spacing4)
        }
        .padding(MindsetLayout.paddingMedium)
        .mindsetCard()
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
