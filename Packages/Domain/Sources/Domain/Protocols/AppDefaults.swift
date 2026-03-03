//
//  AppDefaults.swift
//  Domain
//

/// Abstraction over app-level `UserDefaults` state.
/// Extend this protocol as new persisted app flags are introduced.
public protocol AppDefaults: AnyObject {
    /// Whether the user has completed the onboarding flow.
    var onboardingComplete: Bool { get set }
}
