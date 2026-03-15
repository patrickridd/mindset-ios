//
//  AccountSecurityCallout.swift
//  SharedUI
//
//  Created by patrick ridd on 3/14/26.
//

import SharedUtils
import SwiftUI

public struct AccountSecurityCallout: View {
    private let streakCount: Int
    private let onLinkAction: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    public init(streakCount: Int, onLinkAction: @escaping () -> Void) {
        self.streakCount = streakCount
        self.onLinkAction = onLinkAction
    }
    
    public var body: some View {
        Button(action: {
            HapticManager.action()
            onLinkAction()
        }) {
            HStack(spacing: MindsetLayout.spacing16) {
                ZStack {
                    Circle()
                        .fill(MindsetColors.accentOrangeSoft)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(MindsetColors.accentOrange)
                }
                .shadow(color: MindsetColors.accentOrange.opacity(0.3), radius: 10)
                
                // 2. Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Secure your \(streakCount)-day streak")
                        .font(MindsetFonts.bodyMedium)
                        .foregroundColor(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                    
                    Text("Link your Apple ID to never lose progress.")
                        .font(MindsetFonts.caption)
                        .foregroundColor(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(MindsetColors.textMuted)
            }
            .padding()
        }
        .mindsetCard()
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountSecurityCallout(streakCount: 3) {}
}
