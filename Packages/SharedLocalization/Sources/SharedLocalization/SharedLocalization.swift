import Foundation

/// SharedLocalization provides access to common localized strings used across all feature modules.
/// 
/// This centralizes common UI actions, error messages, validation text, and authentication terms
/// that are shared across multiple features to avoid duplication and ensure consistency.
///
/// **Usage:**
/// ```swift
/// Text(SharedLocalizedString.cancel)
/// Text(SharedLocalizedString.error.somethingWentWrong)
/// ```
///
/// **Categories:**
/// - Common actions: cancel, save, done, continue, back, close
/// - Errors: network errors, generic errors, retry messages
/// - Validation: required fields, invalid input
/// - Authentication: sign in, sign out, account management
public enum SharedLocalizedString {
    
    // MARK: - Common Actions
    
    public static let cancel = String(localized: "cancel", bundle: .module, comment: "Cancel button")
    public static let save = String(localized: "save", bundle: .module, comment: "Save button")
    public static let done = String(localized: "done", bundle: .module, comment: "Done button")
    public static let back = String(localized: "back", bundle: .module, comment: "Back button")
    public static let close = String(localized: "close", bundle: .module, comment: "Close button")
    public static let `continue` = String(localized: "continue", bundle: .module, comment: "Continue button")
    public static let next = String(localized: "next", bundle: .module, comment: "Next button")
    public static let skip = String(localized: "skip", bundle: .module, comment: "Skip button")
    public static let ok = String(localized: "ok", bundle: .module, comment: "OK button")
    public static let confirm = String(localized: "confirm", bundle: .module, comment: "Confirm button")
    public static let delete = String(localized: "delete", bundle: .module, comment: "Delete button")
    public static let edit = String(localized: "edit", bundle: .module, comment: "Edit button")
    public static let share = String(localized: "share", bundle: .module, comment: "Share button")
    public static let retry = String(localized: "retry", bundle: .module, comment: "Retry button")
    public static let submit = String(localized: "submit", bundle: .module, comment: "Submit button")
    
    // MARK: - Error Messages
    
    public enum Error {
        public static let somethingWentWrong = String(localized: "error.somethingWentWrong", bundle: .module, comment: "Generic error message")
        public static let networkError = String(localized: "error.networkError", bundle: .module, comment: "Network connection error")
        public static let noInternetConnection = String(localized: "error.noInternetConnection", bundle: .module, comment: "No internet connection error")
        public static let tryAgain = String(localized: "error.tryAgain", bundle: .module, comment: "Try again message")
        public static let pleaseTryAgainLater = String(localized: "error.pleaseTryAgainLater", bundle: .module, comment: "Please try again later message")
        public static let loadingFailed = String(localized: "error.loadingFailed", bundle: .module, comment: "Loading failed error")
        public static let saveFailed = String(localized: "error.saveFailed", bundle: .module, comment: "Save failed error")
    }
    
    // MARK: - Validation
    
    public enum Validation {
        public static let requiredField = String(localized: "validation.requiredField", bundle: .module, comment: "Required field validation message")
        public static let invalidEmail = String(localized: "validation.invalidEmail", bundle: .module, comment: "Invalid email validation message")
        public static let tooShort = String(localized: "validation.tooShort", bundle: .module, comment: "Input too short validation message")
        public static let tooLong = String(localized: "validation.tooLong", bundle: .module, comment: "Input too long validation message")
    }
    
    // MARK: - Authentication (Common Terms)
    
    public enum Auth {
        public static let signIn = String(localized: "auth.signIn", bundle: .module, comment: "Sign in action")
        public static let signOut = String(localized: "auth.signOut", bundle: .module, comment: "Sign out action")
        public static let account = String(localized: "auth.account", bundle: .module, comment: "Account label")
        public static let profile = String(localized: "auth.profile", bundle: .module, comment: "Profile label")
    }
    
    // MARK: - Loading States
    
    public enum Loading {
        public static let loading = String(localized: "loading.loading", bundle: .module, comment: "Loading indicator text")
        public static let pleaseWait = String(localized: "loading.pleaseWait", bundle: .module, comment: "Please wait message")
        public static let processing = String(localized: "loading.processing", bundle: .module, comment: "Processing message")
    }
    
    // MARK: - General UI
    
    public enum General {
        public static let settings = String(localized: "general.settings", bundle: .module, comment: "Settings label")
        public static let help = String(localized: "general.help", bundle: .module, comment: "Help label")
        public static let about = String(localized: "general.about", bundle: .module, comment: "About label")
        public static let version = String(localized: "general.version", bundle: .module, comment: "Version label")
        public static let feedback = String(localized: "general.feedback", bundle: .module, comment: "Feedback label")
        public static let contactUs = String(localized: "general.contactUs", bundle: .module, comment: "Contact us label")
    }
}
