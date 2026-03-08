//
//  AuthService.swift
//  Domain
//
//  Created by Mindset Team on 2/1/26.
//

import Foundation

/// Authentication credential types supported by the app
/// Domain defines the credential structure without coupling to specific providers
public enum AuthCredential: Sendable {
    /// OAuth credential with identity token (e.g., Apple Sign In, Google Sign In)
    /// - identityToken: OAuth identity token
    /// - nonce: Optional security nonce for providers that require it (Apple)
    /// - accessToken: Optional access token for providers that use it (Google)
    /// - fullName: Optional user's full name (provided on first sign-in)
    case oauth(
        identityToken: String,
        nonce: String? = nil,
        accessToken: String? = nil,
        fullName: String? = nil
    )

    /// Email and password credential
    case email(email: String, password: String)

    /// Anonymous credential for trial/testing without account
    case anonymous
}

/// Provider used to link a permanent account to an existing session (e.g., link Apple to anonymous).
///
/// This stays provider-agnostic by reusing `AuthCredential` as the payload.
public enum AuthProvider: Sendable {
    case credential(AuthCredential)
}

/// Authentication service protocol for user sign-in and identity management
/// Protocol is provider-agnostic - implementations handle specific providers (Firebase, Supabase, etc.)
public protocol AuthService: Sendable {
    /// Sign in with the provided credential
    /// - Parameter credential: Authentication credential (OAuth, email, or anonymous)
    /// - Returns: Authenticated user ID
    func signIn(with credential: AuthCredential) async throws -> String

    /// Get the current authenticated user ID if available
    /// - Returns: User ID if signed in, nil otherwise
    func getCurrentUserID() async -> String?

    /// Sign out the current user
    func signOut() async throws

    /// Sign in anonymously (used for progressive authentication during onboarding).
    ///
    /// Implementations should be idempotent (no-op if already authenticated).
    func signInAnonymously() async throws -> String

    /// Link a permanent account to the currently authenticated user (typically anonymous).
    ///
    /// Implementations must throw a domain error when the credential is already in use so UI can
    /// guide the user to switch accounts instead of linking.
    func linkAccount(with provider: AuthProvider) async throws

    /// Permanently delete the currently authenticated user account.
    ///
    /// Implementations may require a recent login and should surface that error to callers.
    func deleteCurrentUser() async throws

    /// Check if user is currently authenticated
    func isAuthenticated() -> Bool

    /// Check if current user's anonymous account has been linked with provider (gmail, apple, email/password, etc...)
    func isAnonymousAccountLinked() -> Bool

    /// Handle OAuth callback URL (e.g., from Safari after Google Sign In)
    /// - Parameter url: The callback URL from the OAuth flow
    /// - Returns: True if the URL was handled, false otherwise
    func handleAuthCallback(url: URL) -> Bool
}
