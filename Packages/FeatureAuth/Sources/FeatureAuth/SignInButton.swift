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
/// - `icon`: SF Symbol name (e.g. "phone.circle.fill"). Ignored when `imageName` is provided.
/// - `imageName`: Optional asset name for custom logo (e.g. "GoogleLogo" for official Google brand).
/// - `isLoading`: When `nil`, the button manages loading internally (e.g. Google).
///   When provided, uses the external binding (e.g. Phone, which shares viewModel.isLoading).
struct SignInButton: View {
    let icon: String
    let imageName: String?
    let title: String
    let iconColor: Color
    let action: () async -> Void
    @Binding private var externalLoading: Bool?
    @Environment(\.colorScheme) private var colorScheme
    @State private var isSigningIn = false

    private var isLoading: Bool {
        externalLoading ?? isSigningIn
    }

    init(
        icon: String,
        iconColor: Color = .clear,
        imageName: String? = nil,
        title: String,
        action: @escaping () async -> Void
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.imageName = imageName
        self.title = title
        self.action = action
        self._externalLoading = .constant(nil)
    }

    init(
        icon: String,
        iconColor: Color = .clear,
        imageName: String? = nil,
        title: String,
        isLoading: Binding<Bool>,
        action: @escaping () async -> Void
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.imageName = imageName
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
            HStack(alignment: .center, spacing: MindsetLayout.spacing6) {
                if isLoading {
                    ProgressView()
                        .tint(colorScheme == .dark ? Color.black : Color.white)
                } else if let imageName {
                    Image(imageName, bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: MindsetLayout.signInIconButton,
                            height: MindsetLayout.signInIconButton
                        )
                } else {
                    Image(systemName: icon)
                        .font(.system(size: MindsetLayout.signInIconButton, weight: .heavy))
                        .foregroundStyle(iconColor)
                }

                Text(isLoading ? FeatureAuthStrings.signingIn : title)
                    .font(MindsetFonts.buttonSignIn)
            }
            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: MindsetLayout.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                    .fill(colorScheme == .dark ? Color.white : Color.black)
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
        imageName: "GoogleLogo",
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
