//
//  SignInViewModel.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import Observation
import CryptoKit

@Observable
@MainActor
public final class SignInViewModel {
    public var isSigningIn = false
    public var errorMessage: String?
    
    private let onSignInSuccess: (String) -> Void  // Firebase UID
    private let onSkip: () -> Void
    
    public init(
        onSignInSuccess: @escaping (String) -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.onSignInSuccess = onSignInSuccess
        self.onSkip = onSkip
    }
    
    // MARK: - Sign in with Apple
    
    public func handleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        // Generate nonce for security (Firebase requires this)
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        // Store nonce for verification in completion
        UserDefaults.standard.set(nonce, forKey: "currentNonce")
    }
    
    public func handleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Invalid Apple ID credential"
                return
            }
            
            Task {
                await signInWithFirebase(credential: appleIDCredential)
            }
            
        case .failure(let error):
            let asError = error as? ASAuthorizationError
            if asError?.code != .canceled {  // Don't show error if user canceled
                errorMessage = "Sign in failed. Please try again."
            }
        }
    }
    
    private func signInWithFirebase(credential: ASAuthorizationAppleIDCredential) async {
        isSigningIn = true
        
        do {
            guard let nonce = UserDefaults.standard.string(forKey: "currentNonce") else {
                throw NSError(domain: "SignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing nonce"])
            }
            
            guard let appleIDToken = credential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw NSError(domain: "SignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token"])
            }
            
            // Create Firebase credential
            let firebaseCredential = OAuthProvider.credential(
                providerID: .apple,
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            // Sign in to Firebase
            let result = try await Auth.auth().signIn(with: firebaseCredential)
            let firebaseUID = result.user.uid
            
            // Store user info if available (first sign-in only)
            if let fullName = credential.fullName {
                let displayName = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                if !displayName.isEmpty {
                    UserDefaults.standard.set(displayName, forKey: "userName")
                }
            }
            
            isSigningIn = false
            onSignInSuccess(firebaseUID)
            
        } catch {
            isSigningIn = false
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Continue without account
    
    public func continueWithoutAccount() async {
        isSigningIn = true
        
        do {
            // Sign in anonymously to Firebase (for trial/testing)
            let result = try await Auth.auth().signInAnonymously()
            let firebaseUID = result.user.uid
            
            isSigningIn = false
            onSignInSuccess(firebaseUID)
            
        } catch {
            isSigningIn = false
            errorMessage = "Anonymous sign in failed. Please use Sign in with Apple."
        }
    }
    
    // MARK: - Error handling
    
    public func dismissError() {
        errorMessage = nil
    }
    
    // MARK: - Security helpers (nonce generation for Apple Sign In)
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}
