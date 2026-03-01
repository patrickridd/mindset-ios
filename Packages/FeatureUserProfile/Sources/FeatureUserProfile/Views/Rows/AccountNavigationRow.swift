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
    let action: () -> Void // The navigation trigger

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack(spacing: MindsetLayout.spacing16) {
                // ... Your existing Icon/Text ZStack and VStack ...
                
                AccountRow(icon: icon, title: title, subtitle: subtitle, color: color)

                Spacer()

                // The Navigation Indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MindsetColors.textMuted)
            }
        }
        .buttonStyle(.plain) // Prevents the whole row from turning blue/faded
    }
}
