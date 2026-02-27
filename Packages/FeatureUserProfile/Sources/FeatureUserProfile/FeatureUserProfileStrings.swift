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
}
