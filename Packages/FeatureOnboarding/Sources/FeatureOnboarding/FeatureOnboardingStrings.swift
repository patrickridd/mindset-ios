import Foundation

/// Type-safe access to FeatureOnboarding localized strings.
///
/// **Usage:**
/// ```swift
/// Text(FeatureOnboardingStrings.Welcome.title)
/// Text(FeatureOnboardingStrings.Quiz.title)
/// Text(FeatureOnboardingStrings.Pain.overwhelmedTitle)
/// ```
public enum FeatureOnboardingStrings {
    
    // MARK: - Welcome Screen
    
    public enum Welcome {
        public static let title = String(localized: "onboarding.welcome.title", bundle: .module, comment: "Welcome screen title")
        public static let subtitle = String(localized: "onboarding.welcome.subtitle", bundle: .module, comment: "Welcome screen subtitle")
    }
    
    // MARK: - Quiz
    
    public enum Quiz {
        public static let title = String(localized: "onboarding.quiz.title", bundle: .module, comment: "Quiz section title")
    }
    
    // MARK: - Analyzing
    
    public enum Analyzing {
        public static let title = String(localized: "onboarding.analyzing.title", bundle: .module, comment: "Analyzing screen title")
        public static let subtitle = String(localized: "onboarding.analyzing.subtitle", bundle: .module, comment: "Analyzing screen subtitle")
        public static let buildingProfile = String(localized: "onboarding.analyzing.buildingProfile", bundle: .module, comment: "Building your Identity Profile loading message")
        public static let checklistGoals = String(localized: "onboarding.analyzing.checklist.goals", bundle: .module, comment: "Checklist: Analyzing goals")
        public static let checklistArchetypes = String(localized: "onboarding.analyzing.checklist.archetypes", bundle: .module, comment: "Checklist: Calibrating Archetypes")
        public static let checklistYesterdayBridge = String(localized: "onboarding.analyzing.checklist.yesterdayBridge", bundle: .module, comment: "Checklist: Setting up Yesterday Bridge")
    }
    
    // MARK: - Archetype
    
    public enum Archetype {
        public static let title = String(localized: "onboarding.archetype.title", bundle: .module, comment: "Archetype reveal title")
    }
    
    // MARK: - Pain Screens
    
    public enum Pain {
        public static let overwhelmedTitle = String(localized: "onboarding.pain.overwhelmed.title", bundle: .module, comment: "Pain screen 1 title")
        public static let stuckTitle = String(localized: "onboarding.pain.stuck.title", bundle: .module, comment: "Pain screen 2 title")
        public static let habitTitle = String(localized: "onboarding.pain.habit.title", bundle: .module, comment: "Pain screen 3 title")
    }
    
    // MARK: - How App Helps
    
    public enum HowAppHelps {
        public static let title = String(localized: "onboarding.howAppHelps.title", bundle: .module, comment: "How app helps screen title")
    }
    
    // MARK: - Social Proof
    
    public enum SocialProof {
        public static let title = String(localized: "onboarding.socialProof.title", bundle: .module, comment: "Social proof screen title")
        public static let subtitle = String(localized: "onboarding.socialProof.subtitle", bundle: .module, comment: "Social proof screen subtitle")
    }
    
    // MARK: - AI Coach
    
    public enum AICoach {
        public static let title = String(localized: "onboarding.aiCoach.title", bundle: .module, comment: "AI coach intro title")
    }
    
    // MARK: - Custom Plan
    
    public enum CustomPlan {
        public static let title = String(localized: "onboarding.customPlan.title", bundle: .module, comment: "Custom plan screen title")
        public static let duration = String(localized: "onboarding.customPlan.duration", bundle: .module, comment: "Ritual duration")
    }
}
