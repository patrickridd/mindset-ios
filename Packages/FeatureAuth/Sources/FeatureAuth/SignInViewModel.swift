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

    private let signInOrLinkUseCase: SignInOrLinkUseCase
    private let appleSignInCredentialBuilder: AppleSignInCredentialBuilderProtocol
    private let googleSignInCredentialProvider: GoogleSignInCredentialProvider
    private let phoneVerificationProvider: PhoneVerificationProvider
    private let logger: AppLogger
    private let onSignInSuccess: (String) -> Void  // User ID
    private let onSkip: () -> Void
    let onPhoneSignInButtonTapped: () -> Void
    
    let embedInNavigationStack: Bool

    public init(
        signInOrLinkUseCase: SignInOrLinkUseCase,
        appleSignInCredentialBuilder: AppleSignInCredentialBuilderProtocol,
        googleSignInCredentialProvider: GoogleSignInCredentialProvider,
        phoneVerificationProvider: PhoneVerificationProvider,
        logger: AppLogger,
        embedInNavigationStack: Bool = true,
        onPhoneSignInButtonTapped: @escaping () -> Void,
        onSignInSuccess: @escaping (String) -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.signInOrLinkUseCase = signInOrLinkUseCase
        self.appleSignInCredentialBuilder = appleSignInCredentialBuilder
        self.googleSignInCredentialProvider = googleSignInCredentialProvider
        self.phoneVerificationProvider = phoneVerificationProvider
        self.logger = logger
        self.embedInNavigationStack = embedInNavigationStack
        self.onPhoneSignInButtonTapped = onPhoneSignInButtonTapped
        self.onSignInSuccess = onSignInSuccess
        self.onSkip = onSkip
    }
    
    // MARK: - Button actions

    public func dismissButtonTapped() async {
       await signInAnonymously()
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
            let userID = try await signInOrLinkUseCase.execute(with: credential)
            isLoading = false
            onSignInSuccess(userID)

        } catch {
            logger.log("❌ Apple sign-in failed: \(error.localizedDescription)")
            isLoading = false
            errorMessage = FeatureAuthStrings.Error.signInFailedWithError(
                error.localizedDescription)
        }
    }

    // MARK: - Anonymous sign in

    public func signInAnonymously() async {
        isLoading = true
        let anonymousId = try? await signInOrLinkUseCase.execute(with: .anonymous)
        isLoading = false
        onSignInSuccess(anonymousId ?? "Anonymous")
    }

    // MARK: - Sign in with Google

    public func signInWithGoogle() async {
        isLoading = true

        do {
            let credential = try await googleSignInCredentialProvider.fetchCredential()
            let userID = try await signInOrLinkUseCase.execute(with: credential)
            isLoading = false
            onSignInSuccess(userID)

        } catch {
            isLoading = false
            // Don't display user cancelled error
            if let googleError = error as? GoogleSignInError, googleError == .userCancelled {
                return
            }
            errorMessage = FeatureAuthStrings.Error.googleSignInFailed(error.localizedDescription)
        }
    }

    // MARK: - Sign in with Phone

    /// Requests SMS verification code. Returns verificationID on success, nil on error.
    public func requestPhoneVerificationCode(phoneNumber: String) async -> String? {
        errorMessage = nil
        do {
            return try await phoneVerificationProvider.requestVerificationCode(
                phoneNumber: phoneNumber
            )
        } catch {
            logger.log("❌ Phone verification failed: \(error.localizedDescription)")
            errorMessage = FeatureAuthStrings.Error.phoneSignInFailed(error.localizedDescription)
            return nil
        }
    }

    /// Signs in or links with phone credential. Call after user receives SMS and enters code.
    public func signInWithPhone(
        verificationID: String,
        verificationCode: String
    ) async {
        isLoading = true

        do {
            let credential = AuthCredential.phone(
                verificationID: verificationID,
                verificationCode: verificationCode
            )
            let userID = try await signInOrLinkUseCase.execute(with: credential)
            isLoading = false
            onSignInSuccess(userID)

        } catch {
            logger.log("❌ Phone sign-in failed: \(error.localizedDescription)")
            isLoading = false
            errorMessage = FeatureAuthStrings.Error.phoneSignInFailed(error.localizedDescription)
        }
    }

    // MARK: - Error handling

    public func dismissError() {
        errorMessage = nil
    }
}
