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
/// the local `User.userName` when that field is still empty (first secure-account moment).
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

        var userProfile = try await provisionUser(uid: uid, credential: credential)
        if !userProfile.isAccountSecured && isLinkable {
            await persistIsAccountSecured(for: &userProfile)
        }
        await persistOAuthDisplayNameIfNeeded(from: credential)
        return uid
    }

    private func provisionUser(uid: String, credential: AuthCredential) async throws -> User {
        // 1. Resolve the current state (Existing or New)
        let existingProfile = try? await userRepository.fetchUser()

        let profile: User
        if let existing = existingProfile {
            profile = existing
            logger.log("👤 Provisioning: Existing profile found for \(uid)")
        } else {
            let now = Date()
            profile = User(
                id: uid,
                createdAt: now,
                lastUpdatedAt: now,
                userName: "",
                isAccountSecured: false,
                isOnboardingComplete: false
            )
            logger.log("👤 Provisioning: Creating NEW profile for \(uid)")
        }

        // 2. The "Synchronize" Action
        // This triggers the AppUserRepository's logic: Local Save + Background Remote Push
        try await userRepository.saveUser(profile)
        
        return profile
    }

    /// Helper method to set the current ``User``'s ``isAccountSecured`` property to `TRUE` and persist it in Repository
    private func persistIsAccountSecured(for userProfile: inout User) async {
        userProfile.isAccount(secured: true)
        logger.log("🔗 `isAccountSecured` saved to TRUE")
        try? await userRepository.saveUser(userProfile)
    }

    private func persistOAuthDisplayNameIfNeeded(from credential: AuthCredential) async {
        guard case .oauth(_, _, _, let fullName) = credential,
              let trimmed = fullName?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty,
              var profile = try? await userRepository.fetchUser(),
              profile.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }

        profile.userName = trimmed
        try? await userRepository.saveUser(profile)
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
