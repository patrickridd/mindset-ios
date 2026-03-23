//
//  StartViewModel.swift
//  FeatureStart
//

import Domain
import Foundation
import Observation

@Observable
public final class StartViewModel {
    private let signInService: SignInService
    private let logger: AppLogger

    public var isGuestLoading = false
    public var guestErrorMessage: String?

    public var onGetStarted: () -> Void
    public var onAlreadyHaveAccount: () -> Void
    public var onGuestSignedIn: () -> Void

    public init(
        signInService: SignInService,
        logger: AppLogger,
        onGetStarted: @escaping () -> Void,
        onAlreadyHaveAccount: @escaping () -> Void,
        onGuestSignedIn: @escaping () -> Void
    ) {
        self.signInService = signInService
        self.logger = logger
        self.onGetStarted = onGetStarted
        self.onAlreadyHaveAccount = onAlreadyHaveAccount
        self.onGuestSignedIn = onGuestSignedIn
    }

    public func continueAsGuest() {
        guard !isGuestLoading else { return }
        guestErrorMessage = nil
        isGuestLoading = true

        Task { @MainActor in
            do {
                _ = try await signInService.signIn(with: .anonymous)
                logger.log("✅ Start: anonymous sign-in succeeded")
                isGuestLoading = false
                onGuestSignedIn()
            } catch {
                logger.log("⚠️ Start: anonymous sign-in failed: \(error.localizedDescription)")
                isGuestLoading = false
                guestErrorMessage = FeatureStartStrings.Error.guestSignInFailed
            }
        }
    }
}
