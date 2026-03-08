//
//  SignInViewModel.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import AuthenticationServices
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
    private let appleSignInCredentialBuilder: AppleSignInCredentialBuilderProtocol
    private let logger: AppLogger
    private let onSignInSuccess: (String) -> Void  // User ID
    private let onSkip: () -> Void
    let embedInNavigationStack: Bool

    public init(
        authService: AuthService,
        appleSignInCredentialBuilder: AppleSignInCredentialBuilderProtocol,
        logger: AppLogger,
        embedInNavigationStack: Bool = true,
        onSignInSuccess: @escaping (String) -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.authService = authService
        self.appleSignInCredentialBuilder = appleSignInCredentialBuilder
        self.logger = logger
        self.embedInNavigationStack = embedInNavigationStack
        self.onSignInSuccess = onSignInSuccess
        self.onSkip = onSkip
    }

    public func dismissButtonTapped() async {
        let anonymousId = try? await authService.signIn(with: .anonymous)
        onSignInSuccess(anonymousId ?? "Anonymous")
    }

    // MARK: - Sign in with Apple

    public func handleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        appleSignInCredentialBuilder.prepareRequest(request)
    }

    public func handleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = appleSignInCredentialBuilder.credentialFrom(authorization) else {
                errorMessage = FeatureAuthStrings.Error.invalidAppleCredential
                return
            }

            // Bridges sync callback to async; inherits MainActor from caller.
            Task {
                await signInWithAuthCredential(credential)
            }

        case .failure(let error):
            let asError = error as? ASAuthorizationError
            if asError?.code != .canceled {
                errorMessage = FeatureAuthStrings.Error.signInFailed
            }
        }
    }

    private func signInWithAuthCredential(_ credential: AuthCredential) async {
        isLoading = true

        do {
            let userID = try await authService.signIn(with: credential)

            logger.log("✅ Apple sign-in successful: \(userID)")
            isLoading = false
            onSignInSuccess(userID)

        } catch {
            logger.log("❌ Apple sign-in failed: \(error.localizedDescription)")
            isLoading = false
            errorMessage = FeatureAuthStrings.Error.signInFailedWithError(
                error.localizedDescription)
        }
    }

    // MARK: - Continue with Anonymous account

    public func signInAnonymously() async {
        isLoading = true
        do {
            let userID = try await authService.signIn(with: .anonymous)

            logger.log("✅ Anonymous sign-in successful: \(userID)")
            isLoading = false
            onSignInSuccess(userID)
        } catch {
            logger.log("❌ Anonymous sign-in failed: \(error.localizedDescription)")
            isLoading = false
            errorMessage = FeatureAuthStrings.Error.anonymousSignInFailed(
                error.localizedDescription)
        }
    }

    // MARK: - Sign in with Google

    public func signInWithGoogle(idToken: String, accessToken: String) async {
        isLoading = true

        do {
            let credential = AuthCredential.oauth(
                identityToken: "",
                nonce: nil,
                accessToken: nil,
                fullName: nil
            )

            let userID = try await authService.signIn(with: credential)

            logger.log("✅ Google sign-in successful: \(userID)")
            isLoading = false
            onSignInSuccess(userID)

        } catch {
            logger.log("❌ Google sign-in failed: \(error.localizedDescription)")
            isLoading = false
            errorMessage = FeatureAuthStrings.Error.googleSignInFailed(error.localizedDescription)
        }
    }

    // MARK: - Error handling

    public func dismissError() {
        errorMessage = nil
    }
}
