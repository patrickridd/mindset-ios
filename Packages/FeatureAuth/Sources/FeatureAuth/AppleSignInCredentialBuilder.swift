//
//  AppleSignInCredentialBuilder.swift
//  FeatureAuth
//
//  Created by Mindset Team on 3/8/26.
//

import AuthenticationServices
import Domain
import Foundation
import SharedUtils

/// Protocol for building AuthCredential from Apple Sign In authorization.
/// Enables DI and testing without concrete Apple/framework types in callers.
public protocol AppleSignInCredentialBuilderProtocol: Sendable {
    /// Prepare the request with nonce and scopes before presenting Apple Sign In.
    func prepareRequest(_ request: ASAuthorizationAppleIDRequest)

    /// Extract AuthCredential from the authorization result. Returns nil if invalid.
    func credentialFrom(_ authorization: ASAuthorization) -> AuthCredential?
}

/// Builds AuthCredential from Apple Sign In flow. Handles nonce generation, storage,
/// and credential extraction.
public final class AppleSignInCredentialBuilder: AppleSignInCredentialBuilderProtocol, Sendable {
    private let nonceStorage: AppleSignInNonceStorageProtocol

    public init(nonceStorage: AppleSignInNonceStorageProtocol) {
        self.nonceStorage = nonceStorage
    }

    public func prepareRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = AppleSignInNonceGenerator.randomNonceString()
        request.nonce = AppleSignInNonceGenerator.sha256Hash(nonce)
        nonceStorage.store(nonce)
    }

    public func credentialFrom(_ authorization: ASAuthorization) -> AuthCredential? {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return nil
        }

        guard let nonce = nonceStorage.retrieve() else {
            return nil
        }

        guard let appleIDToken = credential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            return nil
        }
        
        nonceStorage.storeUserName(displayName(with: credential))

        return AuthCredential.oauth(
            identityToken: idTokenString,
            nonce: nonce,
            accessToken: nil,
            fullName: fullName(with: credential)
        )
    }

    private func displayName(with credential: ASAuthorizationAppleIDCredential) -> String {
        givenName(with: credential) ?? familyName(with: credential) ?? "Profile"
    }

    private func givenName(with credential: ASAuthorizationAppleIDCredential) -> String? {
        credential.fullName?.givenName?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func familyName(with credential: ASAuthorizationAppleIDCredential) -> String? {
        credential.fullName?.familyName?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func fullName(with credential: ASAuthorizationAppleIDCredential) -> String? {
        let fullName = [givenName(with: credential), familyName(with: credential)]
            .compactMap { $0 }
            .joined(separator: " ")
        return fullName
    }
}
