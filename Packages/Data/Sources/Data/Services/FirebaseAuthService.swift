//
//  FirebaseAuthService.swift
//  Data
//
//  Created by Mindset Team on 2/1/26.
//

import Domain
import FirebaseAuth
import Foundation

// Disambiguate: Domain.AuthCredential vs FirebaseAuth.AuthCredential
public typealias DomainAuthCredential = Domain.AuthCredential
typealias FirebaseAuthCredential = FirebaseAuth.AuthCredential

public final class FirebaseAuthService: AuthService {

    public init() {
        // Firebase should be configured in app initialization (MindsetApp.swift)
    }

    // MARK: - AuthService Protocol

    public func signIn(with credential: DomainAuthCredential) async throws -> String {
        switch credential {
        case .oauth(let identityToken, let nonce, let accessToken, let fullName):
            return try await signInWithOAuth(
                identityToken: identityToken,
                nonce: nonce,
                accessToken: accessToken,
                fullName: fullName
            )

        case .email(let email, let password):
            return try await signInWithEmail(email: email, password: password)

        case .anonymous:
            return try await signInAnonymously()
        }
    }

    public func getCurrentUserID() async -> String? {
        return Auth.auth().currentUser?.uid
    }

    public func signOut() async throws {
        try Auth.auth().signOut()
    }

    public func isAuthenticated() async -> Bool {
        return Auth.auth().currentUser != nil
    }

    public func handleAuthCallback(url: URL) -> Bool {
        // Delegate OAuth callback handling to Firebase
        // Firebase will complete the sign-in flow if the URL matches its OAuth redirect
        return Auth.auth().canHandle(url)
    }

    // MARK: - Private Implementation Details

    private func signInWithOAuth(
        identityToken: String,
        nonce: String?,
        accessToken: String?,
        fullName: String?
    ) async throws -> String {
        // Determine provider based on presence of nonce (Apple) or accessToken (Google)
        if let nonce = nonce {
            // Apple Sign In uses nonce
            let firebaseCredential = OAuthProvider.credential(
                providerID: .apple,
                idToken: identityToken,
                rawNonce: nonce
            )
            let result = try await Auth.auth().signIn(with: firebaseCredential)
            let userID = result.user.uid

            // Store full name if provided (first sign-in only)
            if let fullName = fullName, !fullName.isEmpty {
                try await updateUserProfile(displayName: fullName)
            }

            return userID
        } else {
            // Google Sign In - Use Firebase's built-in OAuth web flow
            // This opens Safari/ASWebAuthenticationSession for Google login
            return try await signInWithGoogleViaFirebase()
        }
    }

    /// Sign in with Google using Firebase's built-in web OAuth flow
    /// No GoogleSignIn SDK needed! Firebase handles everything.
    private func signInWithGoogleViaFirebase() async throws -> String {
        let provider = OAuthProvider(providerID: "google.com")

        // Optional: Request specific scopes
        provider.scopes = ["email", "profile"]

        // Optional: Custom parameters
        provider.customParameters = [
            "prompt": "select_account"  // Forces account picker
        ]

        // Firebase handles the entire OAuth flow via Safari
        // Use callback-based API and convert to async
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: provider, uiDelegate: nil) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let uid = authResult?.user.uid {
                    continuation.resume(returning: uid)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "FirebaseAuthService",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unknown error during Google sign in"
                            ]
                        ))
                }
            }
        }
    }

    private func signInWithEmail(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    private func signInAnonymously() async throws -> String {
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    private func updateUserProfile(displayName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]
            )
        }

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
    }
}
