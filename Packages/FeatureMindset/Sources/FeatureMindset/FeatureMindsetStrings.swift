import Foundation

/// Type-safe access to FeatureMindset localized strings.
///
/// **Usage:**
/// ```swift
/// Text(FeatureMindsetStrings.title)
/// Text(FeatureMindsetStrings.Success.title)
/// Text(FeatureMindsetStrings.Categories.gratitude)
/// ```
public enum FeatureMindsetStrings {
    
    // MARK: - Ritual Screen
    
    public static let title = String(localized: "ritual.title", bundle: .module, comment: "Morning ritual screen title")
    
    // MARK: - Morning Ritual
    
    public enum MorningRitual {
        public static let designingRitual = String(localized: "ritual.morning.designingRitual", bundle: .module, comment: "Loading state when designing ritual")
        public static let fetchingPrompts = String(localized: "ritual.morning.fetchingPrompts", bundle: .module, comment: "Loading state when fetching prompts")
        public static let noPromptsFound = String(localized: "ritual.morning.noPromptsFound", bundle: .module, comment: "Empty state when no prompts available")
        public static let noPromptsFoundDescription = String(localized: "ritual.morning.noPromptsFoundDescription", bundle: .module, comment: "Empty state description for no prompts")
        public static let getAiReflection = String(localized: "ritual.morning.getAiReflection", bundle: .module, comment: "Button to get AI reflection")
        public static let analyzing = String(localized: "ritual.morning.analyzing", bundle: .module, comment: "AI analyzing state")
        public static let complete = String(localized: "ritual.morning.complete", bundle: .module, comment: "Complete button label")
        public static let coachTip = String(localized: "ritual.morning.coachTip", bundle: .module, comment: "Coach tip popover title")
        public static let ritualSuccessLoading = String(localized: "ritual.success.loading", bundle: .module, comment: "Loading/Calculating Ritual Score")
    }
    public static let promptLabel = String(localized: "ritual.promptLabel", bundle: .module, comment: "Prompt label")
    public static let placeholder = String(localized: "ritual.placeholder", bundle: .module, comment: "Text input placeholder")
    public static let submit = String(localized: "ritual.submit", bundle: .module, comment: "Submit button")
    public static let aiAnalyzing = String(localized: "ritual.aiAnalyzing", bundle: .module, comment: "AI analyzing message")
    
    // MARK: - Success
    
    public enum Success {
        public static let title = String(localized: "ritual.success.title", bundle: .module, comment: "Ritual success title")
        public static let streakMessage = String(localized: "ritual.success.streakMessage", bundle: .module, comment: "Streak message on success")
        public static let xpEarned = String(localized: "ritual.success.xpEarned", bundle: .module, comment: "XP earned message")
    }
    
    // MARK: - AI Reflection
    
    public enum AIReflection {
        public static let title = String(localized: "ritual.aiReflection.title", bundle: .module, comment: "AI reflection card title")
    }
    
    // MARK: - Categories
    
    public enum Categories {
        public static let gratitude = String(localized: "ritual.categories.gratitude", bundle: .module, comment: "Gratitude prompt category")
        public static let mementoMori = String(localized: "ritual.categories.mementoMori", bundle: .module, comment: "Memento mori prompt category")
        public static let goalSetting = String(localized: "ritual.categories.goalSetting", bundle: .module, comment: "Goal setting prompt category")
    }
    
    // MARK: - Errors
    
    public enum Error {
        public static let emptyResponse = String(localized: "ritual.error.emptyResponse", bundle: .module, comment: "Empty response error")
    }
}
