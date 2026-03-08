//
//  MockAuthService.swift
//  Domain
//
//  Created by Mindset Team on 2/1/26.
//

import Foundation

/// Mock implementation of AuthService for testing and previews.
///
/// **@MainActor justification:** Used only in previews and tests, which run on MainActor.
/// Production uses FirebaseAuthService (nonisolated).
@MainActor
public final class MockAuthService: @preconcurrency AuthService {

    public var shouldSucceed: Bool
    public var mockUserID: String
    public var signInDelay: Duration

    // Track calls for testing
    public private(set) var signInCalled = false
    public private(set) var lastCredential: AuthCredential?
    public private(set) var signInAnonymouslyCalled = false
    public private(set) var linkAccountCalled = false
    public private(set) var lastLinkProvider: AuthProvider?
    public private(set) var signOutCalled = false
    public private(set) var deleteCurrentUserCalled = false
    public private(set) var isAccountLinked: Bool = false
    
    public init(
        shouldSucceed: Bool = true,
        isAnonymousAccountLinked: Bool = false,
        mockUserID: String = "mock-user-123",
        signInDelay: Duration = .milliseconds(500)
    ) {
        self.shouldSucceed = shouldSucceed
        self.isAccountLinked = isAnonymousAccountLinked
        self.mockUserID = mockUserID
        self.signInDelay = signInDelay
    }

    public func signIn(with credential: AuthCredential) async throws -> String {
        signInCalled = true
        lastCredential = credential
        try await Task.sleep(for: signInDelay)

        if shouldSucceed {
            // Return different IDs for different credential types (useful for testing)
            switch credential {
            case .anonymous:
                return "anonymous-\(mockUserID)"
            case .oauth:
                return "oauth-\(mockUserID)"
            case .phone:
                return "phone-\(mockUserID)"
            }
        } else {
            throw NSError(
                domain: "MockAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mock sign in failed"]
            )
        }
    }

    public func getCurrentUserID() async -> String? {
        return shouldSucceed ? mockUserID : nil
    }

    public func signOut() async throws {
        signOutCalled = true
        try await Task.sleep(for: signInDelay)

        if !shouldSucceed {
            throw NSError(
                domain: "MockAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mock sign out failed"]
            )
        }
    }

    public func signInAnonymously() async throws -> String {
        signInAnonymouslyCalled = true
        return try await signIn(with: .anonymous)
    }

    public func linkAccount(with provider: AuthProvider) async throws {
        linkAccountCalled = true
        lastLinkProvider = provider
        try await Task.sleep(for: signInDelay)

        if !shouldSucceed {
            throw NSError(
                domain: "MockAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mock link account failed"]
            )
        }
    }

    public func deleteCurrentUser() async throws {
        deleteCurrentUserCalled = true
        try await Task.sleep(for: signInDelay)

        if !shouldSucceed {
            throw NSError(
                domain: "MockAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mock delete account failed"]
            )
        }
    }

    public func isAuthenticated() -> Bool {
        shouldSucceed
    }

    public func isAnonymousAccountLinked() -> Bool {
        isAccountLinked
    }

    nonisolated public func handleAuthCallback(url: URL) -> Bool {
        // Mock implementation - always return true for testing
        return true
    }
}
