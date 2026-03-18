//
//  UserProfile.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

import Foundation

public struct UserProfile: Sendable {
    // Identity
    public let id: String
    public let createdAt: Date
    public var userName: String
    public var isAccountSecured: Bool
    public var isOnboardingComplete: Bool
    
    // Feature-Specific Data (Composition)
    public var onboardingData: OnboardingData
    public var stats: UserStats

    public init(id: String, createdAt: Date, userName: String, isAccountSecured: Bool, isOnboardingComplete: Bool, onboardingData: OnboardingData = OnboardingData(), stats: UserStats = UserStats()) {
        self.id = id
        self.createdAt = createdAt
        self.userName = userName
        self.isAccountSecured = isAccountSecured
        self.isOnboardingComplete = isOnboardingComplete
        self.onboardingData = onboardingData
        self.stats = stats
    }

    mutating
    public func update(with onboardingData: OnboardingData) {
        self.onboardingData = onboardingData
    }
    
    mutating
    public func onboarding(isComplete: Bool) {
        self.isOnboardingComplete = isComplete
    }

    mutating
    public func isAccount(secured: Bool) {
        self.isAccountSecured = secured
    }
}
