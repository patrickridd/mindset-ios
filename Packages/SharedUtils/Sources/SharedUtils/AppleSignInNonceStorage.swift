//
//  AppleSignInNonceStorage.swift
//  SharedUtils
//
//  Created by Mindset Team on 3/8/26.
//

import Foundation

/// Keys for Apple Sign In session data stored in UserDefaults.
public enum AppleSignInStorageKey {
    public static let currentNonce = "currentNonce"
    public static let userName = "userName"
}

/// Protocol for storing and retrieving Apple Sign In session data during the OAuth flow.
/// The nonce must persist between request preparation and credential verification.
public protocol AppleSignInNonceStorageProtocol: Sendable {
    /// Store the raw nonce for later verification.
    func store(_ nonce: String)

    /// Retrieve the stored nonce, or nil if none.
    func retrieve() -> String?

    /// Clear the stored nonce.
    func clear()

    /// Store the user's display name (from first Apple Sign In). Used by UserProfileViewModel.
    func storeUserName(_ name: String)

    /// Clear all Apple Sign In session data (nonce and userName). Call on sign out.
    func clearSessionData()
}

/// UserDefaults-backed storage for Apple Sign In nonce and session data.
///
/// **@unchecked Sendable safety invariant:** UserDefaults individual set/get/remove
/// operations are thread-safe. No shared mutable state; each call is independent.
public final class AppleSignInNonceStorage: AppleSignInNonceStorageProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func store(_ nonce: String) {
        userDefaults.set(nonce, forKey: AppleSignInStorageKey.currentNonce)
    }

    public func retrieve() -> String? {
        userDefaults.string(forKey: AppleSignInStorageKey.currentNonce)
    }

    public func clear() {
        userDefaults.removeObject(forKey: AppleSignInStorageKey.currentNonce)
    }

    public func storeUserName(_ name: String) {
        userDefaults.set(name, forKey: AppleSignInStorageKey.userName)
    }

    public func clearSessionData() {
        userDefaults.removeObject(forKey: AppleSignInStorageKey.currentNonce)
        userDefaults.removeObject(forKey: AppleSignInStorageKey.userName)
    }
}
