//
//  UserProfile.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

import Foundation

import Foundation

/// The central domain entity representing a user's identity, progress, and preferences.
///
/// `UserProfile` is the primary aggregate root for all user-specific data. It is designed
/// to be local-first but cloud-syncable. The ``id`` field should correspond directly
/// to the unique identifier provided by the authentication service (e.g., Firebase UID).
public struct UserProfile: Sendable {
    
    // MARK: - Identity
    
    /// The unique identifier for the user.
    /// This matches the `uid` provided by the authentication provider.
    public let id: String
    
    /// The timestamp indicating when the user's account was first created.
    public let createdAt: Date
    
    /// The display name chosen by the user during onboarding.
    public var userName: String
    
    /// A flag indicating if the user has linked their account to a permanent credential (e.g., Apple ID).
    /// Use this to trigger "Secure Your Account" callouts for anonymous users.
    public var isAccountSecured: Bool
    
    /// Indicates whether the user has finished the initial setup flow.
    public var isOnboardingComplete: Bool
    
    // MARK: - Composition
    
    /// The raw responses and goals captured during the initial onboarding session.
    public var onboardingData: OnboardingData
    
    /// Aggregate metrics including streaks, XP, and ritual history.
    public var stats: UserStats

    /// Creates a new UserProfile.
    public init(
        id: String,
        createdAt: Date,
        userName: String,
        isAccountSecured: Bool,
        isOnboardingComplete: Bool,
        onboardingData: OnboardingData = OnboardingData(),
        stats: UserStats = UserStats()
    ) {
        self.id = id
        self.createdAt = createdAt
        self.userName = userName
        self.isAccountSecured = isAccountSecured
        self.isOnboardingComplete = isOnboardingComplete
        self.onboardingData = onboardingData
        self.stats = stats
    }

    /// Updates the user's profile with responses from the onboarding flow.
    mutating public func update(with onboardingData: OnboardingData) {
        self.onboardingData = onboardingData
    }
    
    /// Sets the completion status of the onboarding process.
    mutating public func onboarding(isComplete: Bool) {
        self.isOnboardingComplete = isComplete
    }

    /// Updates the security status of the user's account.
    mutating public func isAccount(secured: Bool) {
        self.isAccountSecured = secured
    }
}
