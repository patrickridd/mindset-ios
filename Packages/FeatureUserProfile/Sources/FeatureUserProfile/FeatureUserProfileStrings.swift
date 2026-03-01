import Foundation

/// Type-safe access to FeatureUserProfile localized strings.
///
/// **Usage:**
/// ```swift
/// Text(FeatureUserProfileStrings.title)
/// Text(FeatureUserProfileStrings.Stats.totalRituals)
/// Text(FeatureUserProfileStrings.Subscription.active)
/// ```
public enum FeatureUserProfileStrings {

    // MARK: - Profile

    public static let title = String(
        localized: "profile.title", bundle: .module, comment: "Profile screen title")

    public static let defaultUserName = String(
        localized: "profile.defaultUserName", bundle: .module,
        comment: "Fallback display name when no user name is set")

    public static let userIdPrefix = String(
        localized: "profile.userIdPrefix", bundle: .module,
        comment: "Label prefix shown before the truncated user ID")

    // MARK: - Stats

    public enum Stats {
        public static let title = String(
            localized: "profile.stats.title", bundle: .module, comment: "Stats section title")
        public static let totalRituals = String(
            localized: "profile.stats.totalRituals", bundle: .module,
            comment: "Total rituals stat label")
        public static let longestStreak = String(
            localized: "profile.stats.longestStreak", bundle: .module,
            comment: "Longest streak stat label")
    }

    // MARK: - Subscription

    public enum Subscription {
        public static let title = String(
            localized: "profile.subscription.title", bundle: .module,
            comment: "Subscription section title")
        public static let active = String(
            localized: "profile.subscription.active", bundle: .module,
            comment: "Active subscription status")
        public static let inactive = String(
            localized: "profile.subscription.inactive", bundle: .module,
            comment: "Inactive subscription status")
    }

    // MARK: - Preferences

    public enum Preferences {
        public static let title = String(
            localized: "profile.preferences.title", bundle: .module,
            comment: "Preferences section title")
        public static let notifications = String(
            localized: "profile.preferences.notifications", bundle: .module,
            comment: "Notifications preference")
        public static let reminderTime = String(
            localized: "profile.preferences.reminderTime", bundle: .module,
            comment: "Reminder time preference")
    }

    // MARK: - Sign Out

    public enum SignOut {
        public static let confirmationTitle = String(
            localized: "profile.signOut.confirmationTitle", bundle: .module,
            comment: "Bottom sheet title asking user to confirm sign out")
        public static let confirmationSubtitle = String(
            localized: "profile.signOut.confirmationSubtitle", bundle: .module,
            comment: "Bottom sheet subtitle below the sign out confirmation title")
        public static let errorTitle = String(
            localized: "profile.signOut.errorTitle", bundle: .module,
            comment: "Alert title shown when sign out fails")
        public static let signingOut = String(
            localized: "profile.signOut.signingOut", bundle: .module,
            comment: "Loading overlay text shown while signing out is in progress")
    }

    // MARK: - Debug Tools (profile row only — screen strings live in Development package)

    public enum DebugTools {
        public static let title = String(
            localized: "profile.debugTools.title", bundle: .module,
            comment: "Navigation title for the Debug Tools screen, also used as the row title")
        public static let rowSubtitle = String(
            localized: "profile.debugTools.rowSubtitle", bundle: .module,
            comment: "Subtitle shown on the Debug Tools navigation row in the profile screen")
    }

    // MARK: - Account Section

    public enum Account {
        public static let signedInTitle = String(
            localized: "profile.account.signedInTitle", bundle: .module,
            comment: "Row title indicating the user is signed in")
        public static let signedInSubtitle = String(
            localized: "profile.account.signedInSubtitle", bundle: .module,
            comment: "Row subtitle reassuring the user their data is secure")
        public static let cloudSyncTitle = String(
            localized: "profile.account.cloudSyncTitle", bundle: .module,
            comment: "Row title indicating cloud sync is active")
        public static let cloudSyncSubtitle = String(
            localized: "profile.account.cloudSyncSubtitle", bundle: .module,
            comment: "Row subtitle indicating all devices are synced")
    }
}
