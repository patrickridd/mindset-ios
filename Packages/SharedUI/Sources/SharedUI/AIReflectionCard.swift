//
//  AIReflectionCard.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/11/26.
//
import SharedUI
import SwiftUI

public struct AIReflectionCard: View {
    let reflection: String?
    let isThinking: Bool

    public init(reflection: String?, isThinking: Bool) {
        self.reflection = reflection
        self.isThinking = isThinking
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(MindsetColors.accentOrange)
                Text("AI REFLECTION")
                    .font(MindsetFonts.labelUppercase)
                    .tracking(1)
            }
            
            if isThinking {
                // Shimmering placeholder logic
                ShimmerPlaceholderView()
            } else if let reflection = reflection {
                TypewriterText(
                    text: reflection,
                    font: MindsetFonts.subheadline,
                    color: MindsetColors.textPrimary
                )
                .fixedSize(horizontal: false, vertical: true)
                .transition(
                    .opacity.combined(
                        with: .move(edge: .bottom)
                    )
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: MindsetLayout.radiusCard))
        .overlay(RoundedRectangle(cornerRadius: MindsetLayout.radiusCard).stroke(MindsetColors.stoicSlateSoft, lineWidth: MindsetLayout.borderWidth))
    }
}

#Preview("AI Thinking") {
    AIReflectionCard(reflection: "That is a good thought", isThinking: true)
}

#Preview("AI Thought") {
    AIReflectionCard(reflection: "That is a great thought!", isThinking: false)
}
