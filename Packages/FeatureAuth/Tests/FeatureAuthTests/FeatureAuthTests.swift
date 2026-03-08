//
//  FeatureAuthTests.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import Domain
import SharedUtils
import Testing

@testable import FeatureAuth

struct FeatureAuthTests {
    private struct TestLogger: AppLogger {
        func log(_ message: String) {}
    }

    private static func makeCredentialBuilder() -> AppleSignInCredentialBuilderProtocol {
        AppleSignInCredentialBuilder(nonceStorage: AppleSignInNonceStorage())
    }

    @Test func signInViewModelInitializesWithAuthService() async throws {
        let mockAuthService = MockAuthService()
        let viewModel = SignInViewModel(
            signInOrLinkUseCase: SignInOrLinkUseCase(authService: mockAuthService),
            appleSignInCredentialBuilder: Self.makeCredentialBuilder(),
            googleSignInCredentialProvider: MockGoogleSignInCredentialProvider(),
            phoneVerificationProvider: MockPhoneVerificationProvider(),
            logger: TestLogger(),
            onSignInSuccess: { _ in },
            onSkip: {}
        )
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func signInAnonymouslyCallsAuthService() async throws {
        let mockAuthService = MockAuthService(signInDelay: .milliseconds(0))
        var receivedUserID: String?

        let viewModel = SignInViewModel(
            signInOrLinkUseCase: SignInOrLinkUseCase(authService: mockAuthService),
            appleSignInCredentialBuilder: Self.makeCredentialBuilder(),
            googleSignInCredentialProvider: MockGoogleSignInCredentialProvider(),
            phoneVerificationProvider: MockPhoneVerificationProvider(),
            logger: TestLogger(),
            onSignInSuccess: { userID in
                receivedUserID = userID
            },
            onSkip: {}
        )

        await viewModel.signInAnonymously()

        #expect(mockAuthService.signInCalled == true)
        if case .anonymous = mockAuthService.lastCredential {
            // Success - correct credential type
        } else {
            Issue.record("Expected anonymous credential")
        }
        #expect(receivedUserID == "anonymous-mock-user-123")
    }

    @Test func signInWithGoogleCallsAuthService() async throws {
        let mockAuthService = MockAuthService(signInDelay: .milliseconds(0))
        let mockGoogleProvider = MockGoogleSignInCredentialProvider()
        var receivedUserID: String?

        let viewModel = SignInViewModel(
            signInOrLinkUseCase: SignInOrLinkUseCase(authService: mockAuthService),
            appleSignInCredentialBuilder: Self.makeCredentialBuilder(),
            googleSignInCredentialProvider: mockGoogleProvider,
            phoneVerificationProvider: MockPhoneVerificationProvider(),
            logger: TestLogger(),
            onSignInSuccess: { userID in
                receivedUserID = userID
            },
            onSkip: {}
        )

        await viewModel.signInWithGoogle()

        #expect(mockAuthService.signInCalled == true)
        if case .oauth(let idToken, let nonce, let accessToken, _) = mockAuthService.lastCredential
        {
            #expect(idToken == "mock-id-token")
            #expect(accessToken == "mock-access-token")
            #expect(nonce == nil)  // Google doesn't use nonce
        } else {
            Issue.record("Expected OAuth credential")
        }
        #expect(receivedUserID == "oauth-mock-user-123")
    }
}
