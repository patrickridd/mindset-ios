//
//  SignInOrLinkUseCaseTests.swift
//  FeatureAuth
//

import Domain
import Foundation
import Testing

@MainActor
struct SignInOrLinkUseCaseTests {

    private static func emptyNamedProfile(id: String = "test-profile-id", userName: String = "") -> User {
        User(
            id: id,
            userName: userName,
            isOnboardingComplete: true,
            overwhelmedFrequency: .sometimes
        )
    }

    @Test
    func execute_oauthSignIn_persistsDisplayNameWhenUserNameEmpty() async throws {
        let repo = MutableMockUserRepository(profile: Self.emptyNamedProfile())
        let auth = MockAuthService(
            shouldSucceed: true,
            isAnonymousAccountLinked: true,
            signInDelay: .milliseconds(0)
        )
        let useCase = SignInOrLinkUseCase(authService: auth, userRepository: repo)
        let credential = AuthCredential.oauth(
            identityToken: "id",
            nonce: nil,
            accessToken: "acc",
            fullName: "Jordan Lee"
        )

        _ = try await useCase.execute(with: credential)

        #expect(repo.profile?.userName == "Jordan Lee")
        #expect(auth.signInCalled == true)
        #expect(auth.linkAccountCalled == false)
    }

    @Test
    func execute_oauthLink_persistsDisplayNameWhenUserNameEmpty() async throws {
        let repo = MutableMockUserRepository(profile: Self.emptyNamedProfile())
        let auth = MockAuthService(
            shouldSucceed: true,
            isAnonymousAccountLinked: false,
            signInDelay: .milliseconds(0)
        )
        let useCase = SignInOrLinkUseCase(authService: auth, userRepository: repo)
        let credential = AuthCredential.oauth(
            identityToken: "id",
            nonce: "nonce",
            accessToken: nil,
            fullName: "Apple User"
        )

        _ = try await useCase.execute(with: credential)

        #expect(repo.profile?.userName == "Apple User")
        #expect(auth.linkAccountCalled == true)
    }

    @Test
    func execute_oauth_doesNotOverwriteExistingUserName() async throws {
        let repo = MutableMockUserRepository(profile: Self.emptyNamedProfile(userName: "Existing"))
        let auth = MockAuthService(
            shouldSucceed: true,
            isAnonymousAccountLinked: true,
            signInDelay: .milliseconds(0)
        )
        let useCase = SignInOrLinkUseCase(authService: auth, userRepository: repo)

        _ = try await useCase.execute(
            with: AuthCredential.oauth(
                identityToken: "id",
                nonce: nil,
                accessToken: "a",
                fullName: "New Name"
            )
        )

        #expect(repo.profile?.userName == "Existing")
    }

    @Test
    func execute_phone_doesNotChangeUserName() async throws {
        let repo = MutableMockUserRepository(profile: Self.emptyNamedProfile())
        let auth = MockAuthService(
            shouldSucceed: true,
            isAnonymousAccountLinked: true,
            signInDelay: .milliseconds(0)
        )
        let useCase = SignInOrLinkUseCase(authService: auth, userRepository: repo)

        _ = try await useCase.execute(
            with: AuthCredential.phone(verificationID: "vid", verificationCode: "123456")
        )

        #expect(repo.profile?.userName == "")
    }

    @Test
    func execute_createsProfileWithIdEqualToUidWhenNoProfileExists() async throws {
        let repo = MutableMockUserRepository(profile: nil)
        let auth = MockAuthService(
            shouldSucceed: true,
            isAnonymousAccountLinked: true,
            mockUserID: "firebase-uid-123",
            signInDelay: .milliseconds(0)
        )
        let useCase = SignInOrLinkUseCase(authService: auth, userRepository: repo)

        let uid = try await useCase.execute(
            with: AuthCredential.oauth(
                identityToken: "id",
                nonce: nil,
                accessToken: "acc",
                fullName: nil
            )
        )

        #expect(repo.profile != nil)
        #expect(repo.profile?.id == uid)
        #expect(repo.profile?.id == "oauth-firebase-uid-123")
    }
}
