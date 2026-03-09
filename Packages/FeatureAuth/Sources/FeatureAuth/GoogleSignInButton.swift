//
//  GoogleSignInButton.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import SharedUI
import SharedUtils
import SwiftUI

struct GoogleSignInButton: View {
    let action: () async -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var isSigningIn = false

    var body: some View {
        Button {
            HapticManager.selection()
            Task {
                await handleGoogleSignIn()
            }
        } label: {
            HStack(spacing: MindsetLayout.spacing12) {
                if isSigningIn {
                    ProgressView()
                        .tint(colorScheme == .dark ? MindsetColors.textPrimary : Color.white)
                } else {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 20))
                }

                Text(
                    isSigningIn ? FeatureAuthStrings.signingIn : FeatureAuthStrings.signInWithGoogle
                )
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
        .disabled(isSigningIn)
    }

    private func handleGoogleSignIn() async {
        isSigningIn = true
        defer { isSigningIn = false }
        await action()
    }
}

#Preview {
    GoogleSignInButton(action: {})
}
