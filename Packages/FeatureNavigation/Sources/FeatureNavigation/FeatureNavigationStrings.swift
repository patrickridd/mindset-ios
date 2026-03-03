import Foundation

/// Type-safe access to FeatureNavigation localized strings.
public enum FeatureNavigationStrings {

    // MARK: - Tabs

    public enum Tab {
        public static let today = String(
            localized: "navigation.tab.today", bundle: .module, comment: "Main tab: Today")
        public static let history = String(
            localized: "navigation.tab.history", bundle: .module, comment: "Main tab: History")
    }
}
