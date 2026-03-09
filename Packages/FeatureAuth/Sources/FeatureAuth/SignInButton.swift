//
//  SignInButton.swift
//  FeatureAuth
//
//  Created by Mindset Team on 3/8/26.
//

import SharedUI
import SharedUtils
import SwiftUI

/// Reusable sign-in button with injectable icon, title, and action.
/// Use for Google, Phone, or other OAuth-style sign-in methods.
///
/// - `isLoading`: When `nil`, the button manages loading internally (e.g. Google).
///   When provided, uses the external binding (e.g. Phone, which shares viewModel.isLoading).
struct SignInButton: View {
    let icon: String
    let title: String
    let action: () async -> Void
    @Binding private var externalLoading: Bool?
    @Environment(\.colorScheme) private var colorScheme
    @State private var isSigningIn = false

    private var isLoading: Bool {
        externalLoading ?? isSigningIn
    }

    init(
        icon: String,
        title: String,
        action: @escaping () async -> Void
    ) {
        self.icon = icon
        self.title = title
        self.action = action
        self._externalLoading = .constant(nil)
    }

    init(
        icon: String,
        title: String,
        isLoading: Binding<Bool>,
        action: @escaping () async -> Void
    ) {
        self.icon = icon
        self.title = title
        self.action = action
        self._externalLoading = Binding<Bool?>(
            get: { .some(isLoading.wrappedValue) },
            set: { _ in }
        )
    }

    var body: some View {
        Button {
            HapticManager.selection()
            Task {
                await performAction()
            }
        } label: {
            HStack(alignment: .center, spacing: MindsetLayout.spacing12) {
                if isLoading {
                    ProgressView()
                        .tint(colorScheme == .dark ? MindsetColors.textPrimary : Color.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                }

                Text(isLoading ? FeatureAuthStrings.signingIn : title)
                    .font(MindsetFonts.button)
            }
            .foregroundStyle(colorScheme == .dark ? MindsetColors.textPrimary : Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: MindsetLayout.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black)
            )
            .overlay(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                    .stroke(MindsetColors.borderSubtle, lineWidth: MindsetLayout.borderWidth)
            )
        }
        .disabled(isLoading)
    }

    private func performAction() async {
        if externalLoading == nil {
            isSigningIn = true
            defer { isSigningIn = false }
        }
        await action()
    }
}

#Preview("Google") {
    SignInButton(
        icon: "g.circle.fill",
        title: FeatureAuthStrings.signInWithGoogle,
        action: {}
    )
}

#Preview("Phone") {
    SignInButton(
        icon: "phone.circle.fill",
        title: FeatureAuthStrings.signInWithPhone,
        action: {}
    )
}
