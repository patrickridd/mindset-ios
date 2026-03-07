//
//  SignInViewModel.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import AuthenticationServices
import CryptoKit
import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class SignInViewModel {
    public var isLoading = false
    public var errorMessage: String?
    var loadingMessage: String = "Setting up..."
    
    private let authService: AuthService
    private let logger: AppLogger
    private let onSignInSuccess: (String) -> Void  // User ID
    private let onSkip: () -> Void
    let embedInNavigationStack: Bool

    public init(
        authService: AuthService,
        logger: AppLogger,
        embedInNavigationStack: Bool = true,
        onSignInSuccess: @escaping (String) -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.authService = authService
        self.logger = logger
        self.embedInNavigationStack = embedInNavigationStack
        self.onSignInSuccess = onSignInSuccess
        self.onSkip = onSkip
    }

    public func dismissButtonTapped() async {
        // User already signed in
        if let userID = await authService.getCurrentUserID() {
            logger.log("Already Signed In ✅ - skipping sign in/up.")
            onSignInSuccess(userID)
        } else {
            logger.log("Signing in anonymously 🤫...")
            await signInAnonymously()
        }
    }

    // MARK: - Sign in with Apple

    public func handleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        // Generate nonce for security (Firebase requires this)
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        // Store nonce for verification in completion
        UserDefaults.standard.set(nonce, forKey: "currentNonce")
    }

    public func handleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let appleIDCredential = authorization.credential
                    as? ASAuthorizationAppleIDCredential
            else {
                errorMessage = "Invalid Apple ID credential"
                return
            }

            Task {
                await signInWithFirebase(credential: appleIDCredential)
            }

        case .failure(let error):
            let asError = error as? ASAuthorizationError
            if asError?.code != .canceled {  // Don't show error if user canceled
                errorMessage = "Sign in failed. Please try again."
            }
        }
    }

    private func signInWithFirebase(credential: ASAuthorizationAppleIDCredential) async {
        isLoading = true

        do {
            guard let nonce = UserDefaults.standard.string(forKey: "currentNonce") else {
                throw NSError(
                    domain: "SignInError", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing nonce"])
            }

            guard let appleIDToken = credential.identityToken,
                let idTokenString = String(data: appleIDToken, encoding: .utf8)
            else {
                throw NSError(
                    domain: "SignInError", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token"])
            }

            // Extract full name if available (first sign-in only)
            var fullName: String?
            if let name = credential.fullName {
                let displayName = [name.givenName, name.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")

                if !displayName.isEmpty {
                    fullName = displayName
                    UserDefaults.standard.set(displayName, forKey: "userName")
                }
            }

            // Create generic OAuth credential (no mention of Apple in Domain!)
            let authCredential = AuthCredential.oauth(
                identityToken: idTokenString,
                nonce: nonce,
                accessToken: nil,
                fullName: fullName
            )

            // Sign in via AuthService protocol
            let userID = try await authService.signIn(with: authCredential)

            logger.log("✅ Apple sign-in successful: \(userID)")
            isLoading = false
            onSignInSuccess(userID)

        } catch {
            logger.log("❌ Apple sign-in failed: \(error.localizedDescription)")
            isLoading = false
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Continue with Anonymous account

    public func signInAnonymously() async {
        isLoading = true
        do {
            // Create anonymous credential
            let credential = AuthCredential.anonymous

            // Sign in via AuthService protocol
            let userID = try await authService.signIn(with: credential)

            logger.log("✅ Anonymous sign-in successful: \(userID)")
            isLoading = false
            onSignInSuccess(userID)

        } catch {
            logger.log("❌ Anonymous sign-in failed: \(error.localizedDescription)")
            isLoading = false
            errorMessage = "Anonymous sign in failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Sign in with Google

    public func signInWithGoogle(idToken: String, accessToken: String) async {
        isLoading = true

        do {
            // Create generic OAuth credential (Firebase will handle the web flow)
            // Empty tokens trigger Firebase's built-in web OAuth
            let credential = AuthCredential.oauth(
                identityToken: "",  // Not needed for Firebase web flow
                nonce: nil,  // Apple only
                accessToken: nil,  // Not needed for Firebase web flow
                fullName: nil
            )

            // Sign in via AuthService protocol
            let userID = try await authService.signIn(with: credential)

            logger.log("✅ Google sign-in successful: \(userID)")
            isLoading = false
            onSignInSuccess(userID)

        } catch {
            logger.log("❌ Google sign-in failed: \(error.localizedDescription)")
            isLoading = false
            errorMessage = "Google sign in failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Error handling

    public func dismissError() {
        errorMessage = nil
    }

    // MARK: - Security helpers (nonce generation for Apple Sign In)

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}
