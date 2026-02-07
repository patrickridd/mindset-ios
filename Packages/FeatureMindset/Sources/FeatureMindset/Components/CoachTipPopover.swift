//
//  CoachTipPopover.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/6/26.
//

import SharedUI
import SwiftUI

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
