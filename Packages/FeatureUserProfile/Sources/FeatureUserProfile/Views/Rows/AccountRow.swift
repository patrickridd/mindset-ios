//
//  AccountRow.swift
//  FeatureUserProfile
//
//  Created by patrick ridd on 3/1/26.
//

import SharedUI
import SwiftUI

struct AccountRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: MindsetLayout.spacing16) {
            ZStack {
                Circle()
                    .fill(color.opacity(colorScheme == .dark ? 0.15 : 0.2))
                    .frame(
                        width: MindsetLayout.iconButtonLarge,
                        height: MindsetLayout.iconButtonLarge)
                
                Image(systemName: icon)
                    .font(.system(size: MindsetLayout.iconLarge))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: MindsetLayout.spacing4) {
                Text(title)
                    .font(MindsetFonts.bodyMedium)
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                
                Text(subtitle)
                    .font(MindsetFonts.caption)
                    .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
            }
            
            Spacer()
        }
        .padding(MindsetLayout.paddingMedium)
    }
}
