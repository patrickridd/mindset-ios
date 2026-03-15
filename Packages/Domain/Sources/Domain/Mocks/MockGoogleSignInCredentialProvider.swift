//
//  MockGoogleSignInCredentialProvider.swift
//  Domain
//
//  Created by Mindset Team on 3/8/26.
//

import Foundation

/// Mock implementation of GoogleSignInCredentialProvider for testing and previews.
public final class MockGoogleSignInCredentialProvider: GoogleSignInCredentialProvider, Sendable {

    private let shouldSucceed: Bool
    private let fullName: String?

    public init(shouldSucceed: Bool = true, fullName: String? = nil) {
        self.shouldSucceed = shouldSucceed
        self.fullName = fullName
    }

    public func fetchCredential() async throws -> AuthCredential {
        guard shouldSucceed else {
            throw NSError(
                domain: "MockGoogleSignInCredentialProvider",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mock Google sign-in failed"]
            )
        }
        return AuthCredential.oauth(
            identityToken: "mock-id-token",
            nonce: nil,
            accessToken: "mock-access-token",
            fullName: fullName
        )
    }
}
