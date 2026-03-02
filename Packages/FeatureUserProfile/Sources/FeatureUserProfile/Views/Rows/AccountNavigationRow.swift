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
        Button(action: {
            HapticManager.selection()
            navigationAction()
        }) {
            HStack(spacing: MindsetLayout.spacing16) {
                AccountRow(icon: icon, title: title, subtitle: subtitle, color: color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(MindsetFonts.bodyMedium)
                    .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                    .padding(.trailing)
            }
        }
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
