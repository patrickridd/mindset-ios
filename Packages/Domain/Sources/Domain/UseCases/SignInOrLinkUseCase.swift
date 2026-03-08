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
/// (Apple, Google with tokens, or email), link the credential to the existing account instead of
/// creating a new one. Preserves onboarding data, ritual history, and subscription state.
public struct SignInOrLinkUseCase: Sendable {
    private let signInService: SignInService
    private let authStateQuery: AuthStateQuery
    private let authSessionManagement: AuthSessionManagement

    public init(
        signInService: SignInService,
        authStateQuery: AuthStateQuery,
        authSessionManagement: AuthSessionManagement
    ) {
        self.signInService = signInService
        self.authStateQuery = authStateQuery
        self.authSessionManagement = authSessionManagement
    }

    /// Convenience init when a single AuthService instance provides all capabilities.
    public init(authService: AuthService) {
        self.signInService = authService
        self.authStateQuery = authService
        self.authSessionManagement = authService
    }

    /// Authenticate with the credential. Links to anonymous account when applicable.
    /// - Parameter credential: Authentication credential (OAuth, email, or anonymous)
    /// - Returns: Authenticated user ID
    public func execute(with credential: AuthCredential) async throws -> String {
        let isAnonymous = authStateQuery.isAuthenticated() && !authStateQuery.isAnonymousAccountLinked()
        let isLinkable = isLinkableCredential(credential)

        if isAnonymous && isLinkable {
            try await authSessionManagement.linkAccount(with: .credential(credential))
            return (await authStateQuery.getCurrentUserID()) ?? ""
        }

        return try await signInService.signIn(with: credential)
    }

    private func isLinkableCredential(_ credential: AuthCredential) -> Bool {
        switch credential {
        case .oauth, .email:
            return true
        case .anonymous:
            return false
        }
    }
}
