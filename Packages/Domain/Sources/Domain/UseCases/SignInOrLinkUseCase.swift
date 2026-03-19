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
    private let logger: AppLogger

    public init(
        signInService: SignInService,
        authStateQuery: AuthStateQuery,
        authSessionManagement: AuthSessionManagement,
        userRepository: UserRepository,
        logger: AppLogger
    ) {
        self.signInService = signInService
        self.authStateQuery = authStateQuery
        self.authSessionManagement = authSessionManagement
        self.userRepository = userRepository
        self.logger = logger
    }

    /// Convenience init when a single AuthService instance provides all capabilities.
    public init(authService: AuthService, userRepository: UserRepository, logger: AppLogger) {
        self.signInService = authService
        self.authStateQuery = authService
        self.authSessionManagement = authService
        self.userRepository = userRepository
        self.logger = logger
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

        var userProfile = try await ensureLocalProfileExists(uid: uid, credential: credential)
        if !userProfile.isAccountSecured && isLinkable {
            await persistIsAccountSecured(for: &userProfile)
        }
        await persistOAuthDisplayNameIfNeeded(from: credential)
        return uid
    }

    private func ensureLocalProfileExists(uid: String, credential: AuthCredential) async throws -> UserProfile {
        if let existingUserProfile = try? await userRepository.fetchUserProfile() {
            return existingUserProfile
        }
        let dateCreated = Date()
        let createUserProfile = UserProfile(
            id: uid,
            createdAt: dateCreated,
            lastUpdatedAt: dateCreated,
            userName: "",
            isAccountSecured: false,
            isOnboardingComplete: false
        )

        try await userRepository.saveUserProfile(createUserProfile)
        return createUserProfile
    }

    /// Helper method to set the current ``UserProfile``'s ``isAccountSecured`` property to `TRUE` and persist it in Repository
    private func persistIsAccountSecured(for userProfile: inout UserProfile) async {
        userProfile.isAccount(secured: true)
        logger.log("🔗 `isAccountSecured` saved to TRUE")
        try? await userRepository.saveUserProfile(userProfile)
    }

    private func persistOAuthDisplayNameIfNeeded(from credential: AuthCredential) async {
        guard case .oauth(_, _, _, let fullName) = credential,
              let trimmed = fullName?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty,
              var profile = try? await userRepository.fetchUserProfile(),
              profile.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }

        profile.userName = trimmed
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
