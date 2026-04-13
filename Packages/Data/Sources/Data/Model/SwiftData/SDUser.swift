//
//  SDUser.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import Domain
import Foundation
import SwiftData

@Model
public final class SDUser {
    @Attribute(.unique) public var id: String
    public var userName: String
    public var createdAt: Date
    public var lastUpdatedAt: Date
    public var isOnboardingComplete: Bool
    public var isAccountSecured: Bool

    // Flattened Onboarding Data
    public var overwhelmFrequency: String
    public var headspaceRaw: String?
    public var mentalMuscleRaw: String?
    public var responseToSetbackRaw: String?
    public var mindsetGoalRaw: String?
    public var aiCoachToneRaw: String?

    // Flattened Stats Data
    public var currentStreak: Int
    public var totalXP: Int
    public var lastUpdated: Date?
    public var archetype: String?
    // SwiftData can store simple [String] arrays natively
    public var badges: [String]

    public init(
        id: String,
        userName: String,
        createdAt: Date,
        lastUpdatedAt: Date,
        isAccountSecured: Bool,
        isOnboardingComplete: Bool,
        overwhelmFrequency: String,
        headspaceRaw: String?,
        mentalMuscleRaw: String?,
        responseToSetbackRaw: String?,
        mindsetGoalRaw: String?,
        aiCoachToneRaw: String?,
        currentStreak: Int = 0,
        totalXP: Int = 0,
        lastUpdated: Date? = nil,
        archetype: String? = nil,
        badges: [String] = []
    ) {
        self.id = id
        self.userName = userName
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdatedAt
        self.isAccountSecured = isAccountSecured
        self.isOnboardingComplete = isOnboardingComplete
        self.overwhelmFrequency = overwhelmFrequency
        self.headspaceRaw = headspaceRaw
        self.mentalMuscleRaw = mentalMuscleRaw
        self.responseToSetbackRaw = responseToSetbackRaw
        self.mindsetGoalRaw = mindsetGoalRaw
        self.aiCoachToneRaw = aiCoachToneRaw
        self.currentStreak = currentStreak
        self.totalXP = totalXP
        self.lastUpdated = lastUpdated
        self.archetype = archetype
        self.badges = badges
    }

    // MARK: - Mapping

    /// Maps `SDUser` to our Domain ``User``.
    public func toDomain() -> User {
        let onboarding = OnboardingData(
            overwhelmFrequency: overwhelmFrequency,
            headspace: headspaceRaw.flatMap { OnboardingData.Headspace(rawValue: $0) },
            mentalMuscle: mentalMuscleRaw.flatMap { OnboardingData.MentalMuscle(rawValue: $0) },
            responseToSetback: responseToSetbackRaw.flatMap {
                OnboardingData.ResponseToSetback(rawValue: $0)
            },
            mindsetGoal: mindsetGoalRaw.flatMap { OnboardingData.MindsetGoal(rawValue: $0) },
            aiCoachTone: aiCoachToneRaw.flatMap { OnboardingData.AICoachTone(rawValue: $0) }
        )

        let stats = UserStats(
            currentStreak: currentStreak,
            totalXP: totalXP,
            lastUpdated: lastUpdated,
            badges: badges,
            archetype: archetype
        )

        return User(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            userName: userName,
            isAccountSecured: isAccountSecured,
            isOnboardingComplete: isOnboardingComplete,
            onboardingData: onboarding,
            stats: stats
        )
    }

    /// Use only for creation (Insert) into Swift Data.
    public static func fromDomain(_ domain: User) -> SDUser {
        SDUser(
            id: domain.id,
            userName: domain.userName,
            createdAt: domain.createdAt,
            lastUpdatedAt: domain.lastUpdatedAt,
            isAccountSecured: domain.isAccountSecured,
            isOnboardingComplete: domain.isOnboardingComplete,
            overwhelmFrequency: domain.onboardingData.overwhelmFrequency,
            headspaceRaw: domain.onboardingData.headspace?.rawValue,
            mentalMuscleRaw: domain.onboardingData.mentalMuscle?.rawValue,
            responseToSetbackRaw: domain.onboardingData.responseToSetback?.rawValue,
            mindsetGoalRaw: domain.onboardingData.mindsetGoal?.rawValue,
            aiCoachToneRaw: domain.onboardingData.aiCoachTone?.rawValue,
            currentStreak: domain.stats.currentStreak,
            totalXP: domain.stats.totalXP,
            lastUpdated: domain.stats.lastUpdated,
            archetype: domain.stats.archetype,
            badges: domain.stats.badges
        )
    }
}

extension SDUser {
    /// UPDATES the current instance using values from a Domain struct
    func update(from domain: User) {
        self.userName = domain.userName
        self.isAccountSecured = domain.isAccountSecured
        self.isOnboardingComplete = domain.isOnboardingComplete

        // Onboarding
        self.headspaceRaw = domain.onboardingData.headspace?.rawValue
        self.mentalMuscleRaw = domain.onboardingData.mentalMuscle?.rawValue
        self.responseToSetbackRaw = domain.onboardingData.responseToSetback?.rawValue
        self.mindsetGoalRaw = domain.onboardingData.mindsetGoal?.rawValue
        self.aiCoachToneRaw = domain.onboardingData.aiCoachTone?.rawValue

        // Stats
        self.currentStreak = domain.stats.currentStreak
        self.totalXP = domain.stats.totalXP
        self.lastUpdated = domain.stats.lastUpdated
        self.archetype = domain.stats.archetype
        self.badges = domain.stats.badges
    }
}
