//
//  FeatureAuthTests.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import Domain
import Testing

@testable import FeatureAuth

struct FeatureAuthTests {
    @Test func signInViewModelInitializesWithAuthService() async throws {
        let mockAuthService = MockAuthService()
        let viewModel = SignInViewModel(
            authService: mockAuthService,
            onSignInSuccess: { _ in },
            onSkip: {}
        )
        #expect(viewModel.isSigningIn == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func signInAnonymouslyCallsAuthService() async throws {
        let mockAuthService = MockAuthService(signInDelay: .milliseconds(10))
        var receivedUserID: String?

        let viewModel = SignInViewModel(
            authService: mockAuthService,
            onSignInSuccess: { userID in
                receivedUserID = userID
            },
            onSkip: {}
        )

        await viewModel.continueWithoutAccount()

        #expect(mockAuthService.signInCalled == true)
        if case .anonymous = mockAuthService.lastCredential {
            // Success - correct credential type
        } else {
            Issue.record("Expected anonymous credential")
        }
        #expect(receivedUserID == "anonymous-mock-user-123")
    }

    @Test func signInWithGoogleCallsAuthService() async throws {
        let mockAuthService = MockAuthService(signInDelay: .milliseconds(10))
        var receivedUserID: String?

        let viewModel = SignInViewModel(
            authService: mockAuthService,
            onSignInSuccess: { userID in
                receivedUserID = userID
            },
            onSkip: {}
        )

        await viewModel.signInWithGoogle(idToken: "mock-token", accessToken: "mock-access")

        #expect(mockAuthService.signInCalled == true)
        if case .oauth(let idToken, let nonce, let accessToken, _) = mockAuthService.lastCredential
        {
            #expect(idToken == "mock-token")
            #expect(accessToken == "mock-access")
            #expect(nonce == nil)  // Google doesn't use nonce
        } else {
            Issue.record("Expected OAuth credential")
        }
        #expect(receivedUserID == "oauth-mock-user-123")
    }
}
