//
//  DefaultPromptQuestionView.swift
//  FeatureMindset
//

import Domain
import SharedUI
import SwiftUI

struct DefaultPromptQuestionView: View {
    
    @Environment(\.colorScheme) private var colorScheme

    let prompt: Prompt

    var body: some View {
        Text(prompt.questionText)
            .font(MindsetFonts.promptQuestion)
            .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
            .multilineTextAlignment(.leading)
            .lineSpacing(MindsetLayout.spacing4)
            .padding([.horizontal, .top], MindsetLayout.paddingSmall)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
