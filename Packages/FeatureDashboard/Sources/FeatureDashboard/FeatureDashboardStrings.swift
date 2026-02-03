import Foundation

/// Type-safe access to FeatureDashboard localized strings.
///
/// **Usage:**
/// ```swift
/// Text(FeatureDashboardStrings.title)
/// Text(FeatureDashboardStrings.Greeting.morning)
/// Text(FeatureDashboardStrings.Streak.title)
/// ```
public enum FeatureDashboardStrings {
    
    // MARK: - Dashboard
    
    public static let title = String(localized: "dashboard.title", bundle: .module, comment: "Dashboard screen title")
    
    // MARK: - Greetings
    
    public enum Greeting {
        public static let morning = String(localized: "dashboard.greeting.morning", bundle: .module, comment: "Morning greeting")
        public static let afternoon = String(localized: "dashboard.greeting.afternoon", bundle: .module, comment: "Afternoon greeting")
        public static let evening = String(localized: "dashboard.greeting.evening", bundle: .module, comment: "Evening greeting")
    }
    
    // MARK: - Streak
    
    public enum Streak {
        public static let title = String(localized: "dashboard.streak.title", bundle: .module, comment: "Streak section title")
        public static let days = String(localized: "dashboard.streak.days", bundle: .module, comment: "Days count for streak")
    }
    
    // MARK: - XP
    
    public enum XP {
        public static let title = String(localized: "dashboard.xp.title", bundle: .module, comment: "XP section title")
    }
    
    // MARK: - Today's Ritual
    
    public enum TodayRitual {
        public static let title = String(localized: "dashboard.todayRitual.title", bundle: .module, comment: "Today's ritual card title")
        public static let completed = String(localized: "dashboard.todayRitual.completed", bundle: .module, comment: "Ritual completed status")
        public static let pending = String(localized: "dashboard.todayRitual.pending", bundle: .module, comment: "Ritual pending status")
    }
    
    // MARK: - Archetype
    
    public enum Archetype {
        public static let title = String(localized: "dashboard.archetype.title", bundle: .module, comment: "Archetype card title")
    }
    
    // MARK: - Weekly Summary
    
    public enum WeeklySummary {
        public static let title = String(localized: "dashboard.weeklySummary.title", bundle: .module, comment: "Weekly summary section title")
        public static let ritualsCompleted = String(localized: "dashboard.weeklySummary.ritualsCompleted", bundle: .module, comment: "Rituals completed count")
    }
}
