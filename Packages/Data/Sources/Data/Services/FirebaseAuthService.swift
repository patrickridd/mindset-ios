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
public typealias DomainAuthProvider = Domain.AuthProvider
typealias FirebaseAuthCredential = FirebaseAuth.AuthCredential

public final class FirebaseAuthService: AuthService, Sendable {

    private let logger: AppLogger

    public init(logger: AppLogger) {
        self.logger = logger
        // Firebase should be configured in app initialization (MindsetApp.swift)
    }

    // MARK: - AuthService Protocol

    public func signIn(with credential: DomainAuthCredential) async throws -> String {
        logger.log("🔐 Auth sign-in started")
        do {
            let uid: String
            switch credential {
            case .oauth(let identityToken, let nonce, let accessToken, let fullName):
                uid = try await signInWithOAuth(
                    identityToken: identityToken,
                    nonce: nonce,
                    accessToken: accessToken,
                    fullName: fullName
                )

            case .email(let email, let password):
                uid = try await signInWithEmail(email: email, password: password)

            case .anonymous:
                uid = try await performAnonymousSignIn()
            }

            logger.log("✅ Auth sign-in successful uid=\(uid)")
            return uid
        } catch {
            logger.log("❌ Auth sign-in failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func getCurrentUserID() async -> String? {
        return Auth.auth().currentUser?.uid
    }

    public func signOut() async throws {
        logger.log("🚪 Auth sign-out requested")
        try Auth.auth().signOut()
        logger.log("✅ Auth sign-out completed")
    }

    public func signInAnonymously() async throws {
        if Auth.auth().currentUser != nil {
            logger.log("🕶️ Anonymous sign-in skipped (already authenticated)")
            return
        }

        logger.log("🕶️ Anonymous sign-in started")
        do {
            _ = try await performAnonymousSignIn()
            logger.log("✅ Anonymous sign-in successful")
        } catch {
            logger.log("❌ Anonymous sign-in failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func linkAccount(with provider: DomainAuthProvider) async throws {
        let providerDescription: String = {
            switch provider {
            case .credential(let credential):
                switch credential {
                case .anonymous:
                    return "anonymous"
                case .email:
                    return "email"
                case .oauth(_, let nonce, let accessToken, _):
                    if nonce != nil { return "apple" }
                    if accessToken != nil { return "google" }
                    return "oauth"
                }
            }
        }()

        logger.log("🔗 Link account started (provider: \(providerDescription))")

        guard let currentUser = Auth.auth().currentUser else {
            logger.log("❌ Link account failed: no authenticated user")
            throw Domain.AuthLinkError.notAuthenticated
        }

        let credential: FirebaseAuthCredential
        switch provider {
        case .credential(let domainCredential):
            credential = try makeFirebaseCredentialForLinking(from: domainCredential)
        }

        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                currentUser.link(with: credential) { _, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }

            logger.log("✅ Link account successful (provider: \(providerDescription)) uid=\(currentUser.uid)")
        } catch {
            if let nsError = error as NSError?,
                AuthErrorCode(_bridgedNSError: nsError) == .credentialAlreadyInUse
            {
                logger.log(
                    "⚠️ Link account failed: credential already in use (provider: \(providerDescription))"
                )
                throw Domain.AuthLinkError.credentialAlreadyInUse
            }

            logger.log(
                "❌ Link account failed (provider: \(providerDescription)): \(error.localizedDescription)"
            )
            throw error
        }
    }

    public func deleteCurrentUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]
            )
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    public func isAuthenticated() async -> Bool {
        return Auth.auth().currentUser != nil
    }

    public func handleAuthCallback(url: URL) -> Bool {
        // Delegate OAuth callback handling to Firebase (iOS).
        // On other platforms, this is a no-op.
        #if canImport(UIKit)
        return Auth.auth().canHandle(url)
        #else
        logger.log("⚠️ OAuth callback handling is not supported on this platform")
        return false
        #endif
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
            #if canImport(UIKit)
            return try await signInWithGoogleViaFirebase()
            #else
            throw NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Google web OAuth is not supported on this platform"
                ]
            )
            #endif
        }
    }

    /// Sign in with Google using Firebase's built-in web OAuth flow
    /// No GoogleSignIn SDK needed! Firebase handles everything.
    #if canImport(UIKit)
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
    #else
    private func signInWithGoogleViaFirebase() async throws -> String {
        throw NSError(
            domain: "FirebaseAuthService",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Google web OAuth is not supported on this platform"
            ]
        )
    }
    #endif

    private func signInWithEmail(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    private func performAnonymousSignIn() async throws -> String {
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

    private func makeFirebaseCredentialForLinking(from credential: DomainAuthCredential) throws
        -> FirebaseAuthCredential
    {
        switch credential {
        case .anonymous:
            throw Domain.AuthLinkError.invalidProviderCredential

        case .email(let email, let password):
            return EmailAuthProvider.credential(withEmail: email, password: password)

        case .oauth(let identityToken, let nonce, let accessToken, _):
            if let nonce {
                guard !identityToken.isEmpty else {
                    throw Domain.AuthLinkError.invalidProviderCredential
                }
                return OAuthProvider.credential(
                    providerID: .apple,
                    idToken: identityToken,
                    rawNonce: nonce
                )
            }

            guard
                let accessToken,
                !identityToken.isEmpty,
                !accessToken.isEmpty
            else {
                throw Domain.AuthLinkError.invalidProviderCredential
            }

            return GoogleAuthProvider.credential(withIDToken: identityToken, accessToken: accessToken)
        }
    }
}
