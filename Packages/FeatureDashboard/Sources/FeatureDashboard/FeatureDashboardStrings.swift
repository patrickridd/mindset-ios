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
    public static let navTitle = String(localized: "dashboard.navTitle", bundle: .module, comment: "Navigation bar title")
    
    // MARK: - Greetings
    
    public enum Greeting {
        public static let morning = String(localized: "dashboard.greeting.morning", bundle: .module, comment: "Morning greeting")
        public static let morningWithComma = String(localized: "dashboard.greeting.morningWithComma", bundle: .module, comment: "Morning greeting with comma for header")
        public static let afternoon = String(localized: "dashboard.greeting.afternoon", bundle: .module, comment: "Afternoon greeting")
        public static let evening = String(localized: "dashboard.greeting.evening", bundle: .module, comment: "Evening greeting")
    }
    
    // MARK: - Profile / Goal
    
    public enum Goal {
        public static let currentLabel = String(localized: "dashboard.goal.currentLabel", bundle: .module, comment: "Current goal card label")
        public static let defaultPlaceholder = String(localized: "dashboard.goal.defaultPlaceholder", bundle: .module, comment: "Default goal when none set")
    }
    
    public static let defaultUserName = String(localized: "dashboard.defaultUserName", bundle: .module, comment: "Default user name when profile missing")
    
    // MARK: - Yesterday
    
    public enum Yesterday {
        public static let label = String(localized: "dashboard.yesterday.label", bundle: .module, comment: "Yesterday's focus section label")
    }
    
    // MARK: - CTA
    
    public enum CTA {
        public static let beginMorningRitual = String(localized: "dashboard.cta.beginMorningRitual", bundle: .module, comment: "Begin morning ritual button")
    }
    
    // MARK: - Streak
    
    public enum Streak {
        public static let title = String(localized: "dashboard.streak.title", bundle: .module, comment: "Streak section title")
        public static let statLabel = String(localized: "dashboard.streak.statLabel", bundle: .module, comment: "Streak stat box label")
        public static let days = String(localized: "dashboard.streak.days", bundle: .module, comment: "Days count for streak")
    }
    
    // MARK: - Rituals
    
    public enum Rituals {
        public static let statLabel = String(localized: "dashboard.rituals.statLabel", bundle: .module, comment: "Rituals stat box label")
        public static let totalFormat = String(localized: "dashboard.rituals.totalFormat", bundle: .module, comment: "Total rituals count format")
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
