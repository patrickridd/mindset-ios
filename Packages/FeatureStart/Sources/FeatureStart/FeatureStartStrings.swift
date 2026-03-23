import Foundation

/// Type-safe access to FeatureStart localized strings.
public enum FeatureStartStrings {

    public enum Screen {
        public static let title = String(
            localized: "start.screen.title",
            bundle: .module,
            comment: "Pre-onboarding welcome title")
        public static let subheadline = String(
            localized: "start.screen.subheadline",
            bundle: .module,
            comment: "Pre-onboarding value proposition subheadline")
    }

    public enum Actions {
        public static let getStarted = String(
            localized: "start.actions.getStarted",
            bundle: .module,
            comment: "Primary CTA to begin onboarding")
        public static let alreadyHaveAccount = String(
            localized: "start.actions.alreadyHaveAccount", bundle: .module,
            comment: "Secondary action to open sign-in")
        public static let continueAsGuest = String(
            localized: "start.actions.continueAsGuest", bundle: .module,
            comment: "Tertiary action to sign in anonymously")
    }

    public enum Error {
        public static let guestSignInFailed = String(
            localized: "start.error.guestSignInFailed", bundle: .module,
            comment: "Shown when anonymous sign-in fails; user can retry")
    }
}
