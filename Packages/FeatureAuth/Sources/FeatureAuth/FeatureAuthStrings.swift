import Foundation

/// Type-safe access to FeatureAuth localized strings.
///
/// **Usage:**
/// ```swift
/// Text(FeatureAuthStrings.signInTitle)
/// Text(FeatureAuthStrings.signInWithApple)
/// Text(FeatureAuthStrings.Error.signInFailed)
/// ```
public enum FeatureAuthStrings {

    // MARK: - Sign In Screen

    public static let signInTitle = String(
        localized: "auth.signInTitle", bundle: .module, comment: "Sign in screen title")
    public static let signInSubtitle = String(
        localized: "auth.signInSubtitle", bundle: .module, comment: "Sign in screen subtitle")
    public static let signInWithApple = String(
        localized: "auth.signInWithApple", bundle: .module, comment: "Sign in with Apple button")
    public static let signInWithGoogle = String(
        localized: "auth.signInWithGoogle", bundle: .module, comment: "Sign in with Google button")
    public static let signInWithPhone = String(
        localized: "auth.signInWithPhone", bundle: .module, comment: "Sign in with Phone button")
    public static let continueAsGuest = String(
        localized: "auth.continueAsGuest", bundle: .module, comment: "Continue as guest option")

    // MARK: - Errors

    public enum Error {
        public static let signInFailed = String(
            localized: "auth.error.signInFailed", bundle: .module, comment: "Sign in failed error")
        public static let cancelled = String(
            localized: "auth.error.cancelled", bundle: .module, comment: "Sign in cancelled message"
        )
        public static let invalidAppleCredential = String(
            localized: "auth.error.invalidAppleCredential", bundle: .module,
            comment: "Invalid Apple ID credential")
        public static let missingNonce = String(
            localized: "auth.error.missingNonce", bundle: .module,
            comment: "Missing nonce error")
        public static let unableToSerializeToken = String(
            localized: "auth.error.unableToSerializeToken", bundle: .module,
            comment: "Unable to serialize token error")
        public static func signInFailedWithError(_ error: String) -> String {
            let format = String(
                localized: "auth.error.signInFailedWithError",
                bundle: .module,
                comment: "Sign in failed with error message"
            )
            return String(format: format, error)
        }
        public static func anonymousSignInFailed(_ error: String) -> String {
            let format = String(
                localized: "auth.error.anonymousSignInFailed",
                bundle: .module,
                comment: "Anonymous sign in failed"
            )
            return String(format: format, error)
        }
        public static func googleSignInFailed(_ error: String) -> String {
            let format = String(
                localized: "auth.error.googleSignInFailed",
                bundle: .module,
                comment: "Google sign in failed"
            )
            return String(format: format, error)
        }
        public static func phoneSignInFailed(_ error: String) -> String {
            let format = String(
                localized: "auth.error.phoneSignInFailed",
                bundle: .module,
                comment: "Phone sign in failed"
            )
            return String(format: format, error)
        }
    }

    // MARK: - Phone Sign In

    public static let phonePlaceholder = String(
        localized: "auth.phonePlaceholder", bundle: .module,
        comment: "Phone number input placeholder")
    public static let sendCode = String(
        localized: "auth.sendCode", bundle: .module,
        comment: "Send verification code button")
    public static let codePlaceholder = String(
        localized: "auth.codePlaceholder", bundle: .module,
        comment: "Verification code input placeholder")
    public static let verify = String(
        localized: "auth.verify", bundle: .module,
        comment: "Verify code button")
    public static let phoneSignInTitle = String(
        localized: "auth.phoneSignInTitle", bundle: .module,
        comment: "Phone sign in sheet title")
}
