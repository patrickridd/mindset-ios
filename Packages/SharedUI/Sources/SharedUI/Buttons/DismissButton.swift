//
//  DismissButton.swift
//  SharedUI
//
//  Reusable top-right close/dismiss button. Use in modals and full-screen flows (onboarding, ritual).
//

import SharedUtils
import SwiftUI

/// A dismiss button (X) aligned to the trailing edge, using design-system styling.
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
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: MindsetLayout.iconSmall, height: MindsetLayout.iconSmall)
                    .foregroundStyle(MindsetColors.dismissButtonIcon(for: colorScheme))
                    .padding(.trailing)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DismissButton(action: {})
}
