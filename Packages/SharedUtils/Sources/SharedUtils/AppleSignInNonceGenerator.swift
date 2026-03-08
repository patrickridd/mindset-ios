//
//  AppleSignInNonceGenerator.swift
//  SharedUtils
//
//  Created by Mindset Team on 3/8/26.
//

import CryptoKit
import Foundation
import Security

/// Cryptographically secure nonce generation and hashing for Apple Sign In.
/// Used when preparing ASAuthorizationAppleIDRequest and verifying credentials with Firebase.
public enum AppleSignInNonceGenerator: Sendable {

    /// Generates a cryptographically secure random nonce string.
    /// - Parameter length: Desired length of the nonce (default 32)
    /// - Returns: Random string suitable for Apple Sign In nonce
    public static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
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

    /// SHA-256 hash of a string, hex-encoded. Required for Apple Sign In request.nonce.
    /// - Parameter input: Raw nonce string to hash
    /// - Returns: Hex-encoded SHA-256 hash
    public static func sha256Hash(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
    }
}
