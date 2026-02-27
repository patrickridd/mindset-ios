//
//  GoogleSignInButton.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import AuthenticationServices
import SharedUI
import SharedUtils
import SwiftUI

struct GoogleSignInButton: View {
    let action: (String, String) -> Void  // idToken, accessToken
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

                Text(isSigningIn ? "Signing in..." : "Continue with Google")
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

        // Get Google OAuth client ID from Firebase config
        // This should come from your Firebase GoogleService-Info.plist
        // For now, we'll pass the tokens via the action callback
        // The actual OAuth flow will be handled by FirebaseAuthService

        // Note: Firebase will handle the web OAuth flow automatically
        // when you call OAuthProvider.credential with Google provider
        // We just need to trigger it through the action callback

        // Placeholder tokens - Firebase will handle the actual OAuth
        action("", "")  // Empty tokens will trigger Firebase's web flow
    }
}
