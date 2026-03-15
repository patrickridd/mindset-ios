//
//  SignInOrLinkUseCase.swift
//  Domain
//
//  Created by Mindset Team on 3/8/26.
//

import Foundation

/// Use case: Authenticate with credential, linking to anonymous account when appropriate.
///
/// Application rule: When the user is anonymously signed in and provides a permanent credential
/// (Apple, Google with tokens, or phone), link the credential to the existing account instead of
/// creating a new one. Preserves onboarding data, ritual history, and subscription state.
///
/// After successful OAuth sign-in or link, a non-empty `fullName` on the credential is written to
/// the local `UserProfile.userName` when that field is still empty (first secure-account moment).
@MainActor
public struct SignInOrLinkUseCase: Sendable {
    private let signInService: SignInService
    private let authStateQuery: AuthStateQuery
    private let authSessionManagement: AuthSessionManagement
    private let userRepository: UserRepository

    public init(
        signInService: SignInService,
        authStateQuery: AuthStateQuery,
        authSessionManagement: AuthSessionManagement,
        userRepository: UserRepository
    ) {
        self.signInService = signInService
        self.authStateQuery = authStateQuery
        self.authSessionManagement = authSessionManagement
        self.userRepository = userRepository
    }

    /// Convenience init when a single AuthService instance provides all capabilities.
    public init(authService: AuthService, userRepository: UserRepository) {
        self.signInService = authService
        self.authStateQuery = authService
        self.authSessionManagement = authService
        self.userRepository = userRepository
    }

    /// Authenticate with the credential. Links to anonymous account when applicable.
    /// - Parameter credential: Authentication credential (OAuth, phone, or anonymous)
    /// - Returns: Authenticated user ID
    public func execute(with credential: AuthCredential) async throws -> String {
        let isAnonymous =
            authStateQuery.isAuthenticated() && !authStateQuery.isAnonymousAccountLinked()
        let isLinkable = isLinkableCredential(credential)

        let uid: String
        if isAnonymous && isLinkable {
            try await authSessionManagement.linkAccount(with: .credential(credential))
            uid = (await authStateQuery.getCurrentUserID()) ?? ""
        } else {
            uid = try await signInService.signIn(with: credential)
        }

        await persistOAuthDisplayNameIfNeeded(from: credential)
        return uid
    }

    private func persistOAuthDisplayNameIfNeeded(from credential: AuthCredential) async {
        guard
            case .oauth(_, _, _, let fullName) = credential, // Get fullName
            let fullName = fullName?.trimmingCharacters(in: .whitespacesAndNewlines), // trim
            var profile = try? await userRepository.fetchUserProfile(), // fetch existing user profile
            profile.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty // existing profile userName isEmpty
        else {
            return
        }

        profile.userName = fullName
        try? await userRepository.saveUserProfile(profile)
    }

    private func isLinkableCredential(_ credential: AuthCredential) -> Bool {
        switch credential {
        case .oauth:
            return true
        case .phone:
            return true
        case .anonymous:
            return false
        }
    }
}
