//
//  DismissButton.swift
//  SharedUI
//
//  Reusable close/dismiss button (circular, xmark). Use in modals and full-screen flows (onboarding, ritual).
//

import SharedUtils
import SwiftUI

/// A dismiss button (circular fill + SF Symbol xmark). Place in top-leading or top-trailing of your header.
public struct DismissButton: View {

    @Environment(\.colorScheme) private var colorScheme

    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            Image(systemName: "xmark")
                .font(.system(size: MindsetLayout.iconSmall, weight: .medium))
                .foregroundStyle(MindsetColors.dismissButtonIcon(for: colorScheme))
                .frame(width: MindsetLayout.dismissButtonCircle, height: MindsetLayout.dismissButtonCircle)
                .background(Circle().fill(MindsetColors.dismissButtonBackground(for: colorScheme)))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DismissButton(action: {})
}
