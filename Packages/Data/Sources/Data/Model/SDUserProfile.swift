//
//  SDUserProfile.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import Domain
import Foundation
import SwiftData

@Model
public final class SDUserProfile {
    @Attribute(.unique) public var id: String
    public var userName: String
    public var createdAt: Date
    public var isOnboardingComplete: Bool
    public var isAccountSecured: Bool
    
    // Flattened Onboarding Data
    public var primaryGoal: String
    public var overwhelmFrequency: String
    public var headspaceRaw: String?
    public var mentalMuscleRaw: String?
    public var responseToSetbackRaw: String?
    public var habitGoalRaw: String?
    public var aiCoachToneRaw: String?
    
    // Flattened Stats Data
    public var streakCount: Int
    public var totalXP: Int
    public var lastRitualDate: Date?
    public var archetype: String?
    // SwiftData can store simple [String] arrays natively
    public var badges: [String]

    public init(
        id: String,
        userName: String,
        createdAt: Date,
        isAccountSecured: Bool,
        isOnboardingComplete: Bool,
        primaryGoal: String,
        overwhelmFrequency: String,
        headspaceRaw: String?,
        mentalMuscleRaw: String?,
        responseToSetbackRaw: String?,
        habitGoalRaw: String?,
        aiCoachToneRaw: String?,
        streakCount: Int = 0,
        totalXP: Int = 0,
        lastRitualDate: Date? = nil,
        archetype: String? = nil,
        badges: [String] = []
    ) {
        self.id = id
        self.userName = userName
        self.createdAt = createdAt
        self.isAccountSecured = isAccountSecured
        self.isOnboardingComplete = isOnboardingComplete
        self.primaryGoal = primaryGoal
        self.overwhelmFrequency = overwhelmFrequency
        self.headspaceRaw = headspaceRaw
        self.mentalMuscleRaw = mentalMuscleRaw
        self.responseToSetbackRaw = responseToSetbackRaw
        self.habitGoalRaw = habitGoalRaw
        self.aiCoachToneRaw = aiCoachToneRaw
        self.streakCount = streakCount
        self.totalXP = totalXP
        self.lastRitualDate = lastRitualDate
        self.archetype = archetype
        self.badges = badges
    }

    // MARK: - Mapping

    /// Maps `SDUserProfile` to our Domain's `UserProfile`
    public func toDomain() -> UserProfile {
        let onboarding = OnboardingData(
            overwhelmFrequency: overwhelmFrequency,
            primaryGoal: primaryGoal,
            headspace: headspaceRaw.flatMap { OnboardingData.Headspace(rawValue: $0) },
            mentalMuscle: mentalMuscleRaw.flatMap { OnboardingData.MentalMuscle(rawValue: $0) },
            responseToSetback: responseToSetbackRaw.flatMap { OnboardingData.ResponseToSetback(rawValue: $0) },
            habitGoal: habitGoalRaw.flatMap { OnboardingData.HabitGoal(rawValue: $0) },
            aiCoachTone: aiCoachToneRaw.flatMap { OnboardingData.AICoachTone(rawValue: $0) }
        )
        
        let stats = UserStats(
            streakCount: streakCount,
            totalXP: totalXP,
            lastRitualDate: lastRitualDate,
            badges: badges,
            archetype: archetype
        )
        
        return UserProfile(
            id: id,
            createdAt: createdAt,
            userName: userName,
            isAccountSecured: isAccountSecured,
            isOnboardingComplete: isOnboardingComplete,
            onboardingData: onboarding,
            stats: stats
        )
    }

    /// Use only for creation (Insert) into Swift Data.
    public static func fromDomain(_ domain: UserProfile) -> SDUserProfile {
        SDUserProfile(
            id: domain.id,
            userName: domain.userName,
            createdAt: domain.createdAt,
            isAccountSecured: domain.isAccountSecured,
            isOnboardingComplete: domain.isOnboardingComplete,
            primaryGoal: domain.onboardingData.primaryGoal,
            overwhelmFrequency: domain.onboardingData.overwhelmFrequency,
            headspaceRaw: domain.onboardingData.headspace?.rawValue,
            mentalMuscleRaw: domain.onboardingData.mentalMuscle?.rawValue,
            responseToSetbackRaw: domain.onboardingData.responseToSetback?.rawValue,
            habitGoalRaw: domain.onboardingData.habitGoal?.rawValue,
            aiCoachToneRaw: domain.onboardingData.aiCoachTone?.rawValue,
            streakCount: domain.stats.streakCount,
            totalXP: domain.stats.totalXP,
            lastRitualDate: domain.stats.lastRitualDate,
            archetype: domain.stats.archetype,
            badges: domain.stats.badges
        )
    }
}

extension SDUserProfile {
    /// UPDATES the current instance using values from a Domain struct
    func update(from domain: UserProfile) {
        self.userName = domain.userName
        self.isAccountSecured = domain.isAccountSecured
        self.isOnboardingComplete = domain.isOnboardingComplete
        
        // Onboarding
        self.primaryGoal = domain.onboardingData.primaryGoal
        self.headspaceRaw = domain.onboardingData.headspace?.rawValue
        self.mentalMuscleRaw = domain.onboardingData.mentalMuscle?.rawValue
        self.responseToSetbackRaw = domain.onboardingData.responseToSetback?.rawValue
        self.habitGoalRaw = domain.onboardingData.habitGoal?.rawValue
        self.aiCoachToneRaw = domain.onboardingData.aiCoachTone?.rawValue
        
        // Stats
        self.streakCount = domain.stats.streakCount
        self.totalXP = domain.stats.totalXP
        self.lastRitualDate = domain.stats.lastRitualDate
        self.archetype = domain.stats.archetype
        self.badges = domain.stats.badges
    }
}
