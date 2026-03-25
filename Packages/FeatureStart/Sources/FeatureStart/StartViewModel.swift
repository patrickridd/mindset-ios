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
    private let userRepository: UserRepository
    private let logger: AppLogger

    public var isGuestLoading = false
    public var guestErrorMessage: String?

    public var onGetStarted: () -> Void
    public var onAlreadyHaveAccount: () -> Void
    public var onGuestSignedIn: () -> Void

    public init(
        signInService: SignInService,
        userRepository: UserRepository,
        logger: AppLogger,
        onGetStarted: @escaping () -> Void,
        onAlreadyHaveAccount: @escaping () -> Void,
        onGuestSignedIn: @escaping () -> Void
    ) {
        self.signInService = signInService
        self.userRepository = userRepository
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
                let userId = try await signInService.signIn(with: .anonymous)
                let user = UserProfile.anonymousUser(id: userId)
                try await userRepository.saveUserProfile(user)
                isGuestLoading = false
                onGuestSignedIn()
            } catch {
                isGuestLoading = false
                guestErrorMessage = FeatureStartStrings.Error.guestSignInFailed
            }
        }
    }
}
