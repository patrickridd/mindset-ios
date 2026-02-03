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
    
    public static let signInTitle = String(localized: "auth.signInTitle", bundle: .module, comment: "Sign in screen title")
    public static let signInSubtitle = String(localized: "auth.signInSubtitle", bundle: .module, comment: "Sign in screen subtitle")
    public static let signInWithApple = String(localized: "auth.signInWithApple", bundle: .module, comment: "Sign in with Apple button")
    public static let signInWithGoogle = String(localized: "auth.signInWithGoogle", bundle: .module, comment: "Sign in with Google button")
    public static let continueAsGuest = String(localized: "auth.continueAsGuest", bundle: .module, comment: "Continue as guest option")
    
    // MARK: - Errors
    
    public enum Error {
        public static let signInFailed = String(localized: "auth.error.signInFailed", bundle: .module, comment: "Sign in failed error")
        public static let cancelled = String(localized: "auth.error.cancelled", bundle: .module, comment: "Sign in cancelled message")
    }
}
