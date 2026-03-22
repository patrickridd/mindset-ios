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
            MindsetIconView(icon: icon, color: color)
            labelStack
            Spacer()
        }
        .padding(MindsetLayout.paddingMedium)
    }

    private var iconBackgroundOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.2
    }
}

// MARK: - Subviews

extension AccountRow {
    private var labelStack: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing4) {
            Text(title)
                .font(MindsetFonts.bodyMedium)
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))

            Text(subtitle)
                .font(MindsetFonts.caption)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        AccountRow(
            icon: "checkmark.shield.fill",
            title: "Signed In",
            subtitle: "Your account is active",
            color: MindsetColors.successEmerald
        )
    }
    .mindsetCard()
    .padding()
}
