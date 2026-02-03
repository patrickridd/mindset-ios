import Foundation

/// Type-safe access to FeatureHistory localized strings.
///
/// **Usage:**
/// ```swift
/// Text(FeatureHistoryStrings.title)
/// Text(FeatureHistoryStrings.Empty.title)
/// Text(FeatureHistoryStrings.Filter.week)
/// ```
public enum FeatureHistoryStrings {
    
    // MARK: - History
    
    public static let title = String(localized: "history.title", bundle: .module, comment: "History screen title")
    public static let export = String(localized: "history.export", bundle: .module, comment: "Export button")
    
    // MARK: - Empty State
    
    public enum Empty {
        public static let title = String(localized: "history.empty.title", bundle: .module, comment: "Empty state title")
        public static let message = String(localized: "history.empty.message", bundle: .module, comment: "Empty state message")
    }
    
    // MARK: - Filters
    
    public enum Filter {
        public static let all = String(localized: "history.filter.all", bundle: .module, comment: "All entries filter")
        public static let week = String(localized: "history.filter.week", bundle: .module, comment: "This week filter")
        public static let month = String(localized: "history.filter.month", bundle: .module, comment: "This month filter")
    }
    
    // MARK: - Search
    
    public enum Search {
        public static let placeholder = String(localized: "history.search.placeholder", bundle: .module, comment: "Search placeholder")
    }
}
