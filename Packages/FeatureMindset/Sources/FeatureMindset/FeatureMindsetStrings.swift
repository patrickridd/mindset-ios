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
