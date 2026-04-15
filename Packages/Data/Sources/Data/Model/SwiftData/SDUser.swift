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

    // --- Refactored Onboarding Data (5-Question Logic) ---
    // We keep these flat for SwiftData performance and reliability.
    public var headspaceRaw: String?
    public var targetEmotionRaw: String?
    public var responseToSetbackRaw: String?
    public var planningStyleRaw: String?
    public var aiCoachToneRaw: String?

    // --- Stats Data ---
    public var currentStreak: Int
    public var totalXP: Int
    public var lastUpdated: Date?
    public var archetype: String?
    public var badges: [String]

    public init(
        id: String,
        userName: String,
        createdAt: Date,
        lastUpdatedAt: Date,
        isAccountSecured: Bool,
        isOnboardingComplete: Bool,
        headspaceRaw: String?,
        targetEmotionRaw: String?,
        responseToSetbackRaw: String?,
        planningStyleRaw: String?,
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
        self.headspaceRaw = headspaceRaw
        self.targetEmotionRaw = targetEmotionRaw
        self.responseToSetbackRaw = responseToSetbackRaw
        self.planningStyleRaw = planningStyleRaw
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
            headspace: headspaceRaw.flatMap { OnboardingData.Headspace(rawValue: $0) },
            targetEmotion: targetEmotionRaw.flatMap { OnboardingData.TargetEmotion(rawValue: $0) },
            responseToSetback: responseToSetbackRaw.flatMap { OnboardingData.ResponseToSetback(rawValue: $0) },
            planningStyle: planningStyleRaw.flatMap { OnboardingData.PlanningStyle(rawValue: $0) },
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

    public static func fromDomain(_ domain: User) -> SDUser {
        SDUser(
            id: domain.id,
            userName: domain.userName,
            createdAt: domain.createdAt,
            lastUpdatedAt: domain.lastUpdatedAt,
            isAccountSecured: domain.isAccountSecured,
            isOnboardingComplete: domain.isOnboardingComplete,
            headspaceRaw: domain.onboardingData.headspace?.rawValue,
            targetEmotionRaw: domain.onboardingData.targetEmotion?.rawValue,
            responseToSetbackRaw: domain.onboardingData.responseToSetback?.rawValue,
            planningStyleRaw: domain.onboardingData.planningStyle?.rawValue,
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
    func update(from domain: User) {
        self.userName = domain.userName
        self.isAccountSecured = domain.isAccountSecured
        self.isOnboardingComplete = domain.isOnboardingComplete
        self.lastUpdatedAt = Date()

        // Updated Onboarding
        self.headspaceRaw = domain.onboardingData.headspace?.rawValue
        self.targetEmotionRaw = domain.onboardingData.targetEmotion?.rawValue
        self.responseToSetbackRaw = domain.onboardingData.responseToSetback?.rawValue
        self.planningStyleRaw = domain.onboardingData.planningStyle?.rawValue
        self.aiCoachToneRaw = domain.onboardingData.aiCoachTone?.rawValue

        // Stats
        self.currentStreak = domain.stats.currentStreak
        self.totalXP = domain.stats.totalXP
        self.lastUpdated = domain.stats.lastUpdated
        self.archetype = domain.stats.archetype
        self.badges = domain.stats.badges
    }
}
