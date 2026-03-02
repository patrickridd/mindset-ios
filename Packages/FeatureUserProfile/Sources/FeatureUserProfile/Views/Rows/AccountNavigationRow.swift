//
//  AccountNavigationRow.swift
//  FeatureUserProfile
//
//  Created by patrick ridd on 3/1/26.
//

import SharedUI
import SharedUtils
import SwiftUI

struct AccountNavigationRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let navigationAction: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 0) {
                AccountRow(icon: icon, title: title, subtitle: subtitle, color: color)
                chevronIcon
            }
        }
        .buttonStyle(.plain)
    }

    private func handleTap() {
        HapticManager.selection()
        navigationAction()
    }
}

// MARK: - Subviews

extension AccountNavigationRow {
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(MindsetFonts.bodyMedium)
            .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
            .padding(.trailing, MindsetLayout.paddingMedium)
    }
}

#Preview {
    AccountNavigationRow(
        icon: "person.badge.key.fill",
        title: "Security Settings",
        subtitle: "Manage your recovery keys",
        color: MindsetColors.accentOrange,
        navigationAction: {}
    )
}
