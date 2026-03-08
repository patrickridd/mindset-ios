//
//  GoogleSignInCredentialProviderImpl.swift
//  Data
//
//  Created by Mindset Team on 3/8/26.
//

import Domain
import FirebaseCore
import Foundation
import GoogleSignIn
import SharedUtils

#if canImport(UIKit)
    import UIKit
#endif

/// Firebase implementation of GoogleSignInCredentialProvider using the Google Sign-In SDK.
public final class GoogleSignInCredentialProviderImpl: GoogleSignInCredentialProvider, Sendable {

    private let logger: AppLogger

    public init(logger: AppLogger) {
        self.logger = logger
    }

    public func fetchCredential() async throws -> AuthCredential {
        #if canImport(UIKit)
            ensureGIDSignInConfigured()
            guard let rootVC = resolveRootViewController() else {
                logger.log("❌ Google Sign-In: No root view controller available")
                throw GoogleSignInError.noRootViewController
            }

            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
                let user = result.user

                var idTokenString: String?
                if let idToken = user.idToken {
                    idTokenString = idToken.tokenString
                } else {
                    let refreshedUser = try await user.refreshTokensIfNeeded()
                    idTokenString = refreshedUser.idToken?.tokenString
                }

                guard let idToken = idTokenString, !idToken.isEmpty else {
                    logger.log("❌ Google Sign-In: No ID token available")
                    throw GoogleSignInError.missingIDToken
                }

                let accessToken = user.accessToken.tokenString
                guard !accessToken.isEmpty else {
                    logger.log("❌ Google Sign-In: No access token available")
                    throw GoogleSignInError.missingAccessToken
                }

                logger.log("🤖 Google Sign-In SDK successful ✅")
                return AuthCredential.oauth(
                    identityToken: idToken,
                    nonce: nil,
                    accessToken: accessToken,
                    fullName: nil
                )
            } catch {
                let nsError = error as NSError
                if nsError.domain == "com.google.GIDSignIn" && nsError.code == -5 {
                    logger.log("📵 Google Sign-In: User cancelled")
                    throw GoogleSignInError.userCancelled
                }
                logger.log("❌ Google Sign-In failed: \(error.localizedDescription)")
                throw error
            }
        #else
            logger.log("⚠️ Google Sign-In SDK is not supported on this platform")
            throw GoogleSignInError.unsupportedPlatform
        #endif
    }

    #if canImport(UIKit)
        private func ensureGIDSignInConfigured() {
            guard GIDSignIn.sharedInstance.configuration == nil,
                let clientID = FirebaseApp.app()?.options.clientID
            else { return }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        private func resolveRootViewController() -> UIViewController? {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.compactMap { $0 as? UIWindowScene }.first
            let window = windowScene?.windows.first { $0.isKeyWindow }
            return window?.rootViewController
        }
    #endif
}
