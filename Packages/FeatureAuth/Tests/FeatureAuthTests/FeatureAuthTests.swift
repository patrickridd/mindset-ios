//
//  FeatureAuthTests.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import Testing
@testable import FeatureAuth

struct FeatureAuthTests {
    @Test func signInViewModelInitializes() async throws {
        let viewModel = SignInViewModel(
            onSignInSuccess: { _ in },
            onSkip: {}
        )
        #expect(viewModel.isSigningIn == false)
        #expect(viewModel.errorMessage == nil)
    }
}
