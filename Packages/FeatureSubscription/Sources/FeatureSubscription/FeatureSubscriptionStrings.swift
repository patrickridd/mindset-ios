import Foundation

/// Type-safe access to FeatureSubscription localized strings.
///
/// **Usage:**
/// ```swift
/// Text(FeatureSubscriptionStrings.title)
/// Text(FeatureSubscriptionStrings.Feature.aiCoach)
/// Text(FeatureSubscriptionStrings.Plan.yearlyTitle)
/// ```
public enum FeatureSubscriptionStrings {
    
    // MARK: - Paywall
    
    public static let title = String(localized: "paywall.title", bundle: .module, comment: "Paywall title")
    public static let subtitle = String(localized: "paywall.subtitle", bundle: .module, comment: "Paywall subtitle")
    public static let restore = String(localized: "paywall.restore", bundle: .module, comment: "Restore purchases button")
    public static let terms = String(localized: "paywall.terms", bundle: .module, comment: "Terms of service link")
    public static let privacy = String(localized: "paywall.privacy", bundle: .module, comment: "Privacy policy link")
    
    // MARK: - Features
    
    public enum Feature {
        public static let aiCoach = String(localized: "paywall.feature.aiCoach", bundle: .module, comment: "AI coach feature")
        public static let unlimitedRituals = String(localized: "paywall.feature.unlimitedRituals", bundle: .module, comment: "Unlimited rituals feature")
        public static let curatedPrompts = String(localized: "paywall.feature.curatedPrompts", bundle: .module, comment: "Curated prompts feature")
        public static let streakTracking = String(localized: "paywall.feature.streakTracking", bundle: .module, comment: "Streak tracking feature")
        public static let weeklySummaries = String(localized: "paywall.feature.weeklySummaries", bundle: .module, comment: "Weekly summaries feature")
        public static let cloudSync = String(localized: "paywall.feature.cloudSync", bundle: .module, comment: "Cloud sync feature")
    }
    
    // MARK: - Plans
    
    public enum Plan {
        public static let monthlyTitle = String(localized: "paywall.plan.monthly.title", bundle: .module, comment: "Monthly plan title")
        public static let yearlyTitle = String(localized: "paywall.plan.yearly.title", bundle: .module, comment: "Yearly plan title")
        public static let yearlyBadge = String(localized: "paywall.plan.yearly.badge", bundle: .module, comment: "Yearly plan savings badge")
    }
    
    // MARK: - CTA
    
    public enum CTA {
        public static let subscribe = String(localized: "paywall.cta.subscribe", bundle: .module, comment: "Subscribe button")
    }
}
