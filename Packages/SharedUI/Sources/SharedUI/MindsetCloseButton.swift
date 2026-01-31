//
//  MindsetCloseButton.swift
//  SharedUI
//
//  Reusable top-right close/dismiss button. Use in modals and full-screen flows (onboarding, ritual).
//

import SwiftUI

/// A close button (X) aligned to the trailing edge, using design-system styling.
public struct MindsetCloseButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: MindsetLayout.iconSmall, height: MindsetLayout.iconSmall)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(MindsetColors.textSecondary)
                    .padding(.trailing)
            }
        }
        .buttonStyle(.plain)
    }
}
