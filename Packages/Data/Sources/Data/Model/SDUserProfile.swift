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
    @Attribute(.unique) public var id: UUID
    public var bestSelfName: String
    public var primaryGoal: String
    public var createdAt: Date
    public var isOnboardingComplete: Bool
    public var isAccountSecured: Bool
    public var overwhelmedFrequency: String

    // Onboarding quiz results (raw values for optional enums)
    public var headspaceRaw: String?
    public var mentalMuscleRaw: String?
    public var responseToSetbackRaw: String?
    public var habitGoalRaw: String?
    public var aiCoachToneRaw: String?

    public init(
        id: UUID = UUID(),
        bestSelfName: String,
        primaryGoal: String,
        isOnboardingComplete: Bool,
        isAccountSecured: Bool = false,
        overwhelmedFrequency: String,
        headspaceRaw: String? = nil,
        mentalMuscleRaw: String? = nil,
        responseToSetbackRaw: String? = nil,
        habitGoalRaw: String? = nil,
        aiCoachToneRaw: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.bestSelfName = bestSelfName
        self.primaryGoal = primaryGoal
        self.isOnboardingComplete = isOnboardingComplete
        self.isAccountSecured = isAccountSecured
        self.overwhelmedFrequency = overwhelmedFrequency
        self.headspaceRaw = headspaceRaw
        self.mentalMuscleRaw = mentalMuscleRaw
        self.responseToSetbackRaw = responseToSetbackRaw
        self.habitGoalRaw = habitGoalRaw
        self.aiCoachToneRaw = aiCoachToneRaw
        self.createdAt = createdAt
    }

    // MARK: - Mapping

    /// Converts SwiftData storage model back to the clean Domain struct
    public func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            userName: bestSelfName,
            primaryGoal: primaryGoal,
            isOnboardingComplete: isOnboardingComplete,
            isAccountSecured: isAccountSecured,
            overwhelmedFrequency: UserProfile.OverwhelmedFrequency(rawValue: overwhelmedFrequency)
                ?? .sometimes,
            headspace: headspaceRaw.flatMap { UserProfile.Headspace(rawValue: $0) },
            mentalMuscle: mentalMuscleRaw.flatMap { UserProfile.MentalMuscle(rawValue: $0) },
            responseToSetback: responseToSetbackRaw.flatMap {
                UserProfile.ResponseToSetback(rawValue: $0)
            },
            habitGoal: habitGoalRaw.flatMap { UserProfile.HabitGoal(rawValue: $0) },
            aiCoachTone: aiCoachToneRaw.flatMap { UserProfile.AICoachTone(rawValue: $0) },
            createdAt: createdAt
        )
    }

    /// Static helper to create a storage model from a Domain struct
    public static func fromDomain(_ domain: UserProfile) -> SDUserProfile {
        SDUserProfile(
            id: domain.id,
            bestSelfName: domain.userName,
            primaryGoal: domain.primaryGoal,
            isOnboardingComplete: domain.isOnboardingComplete,
            isAccountSecured: domain.isAccountSecured,
            overwhelmedFrequency: domain.overwhelmedFrequency.rawValue,
            headspaceRaw: domain.headspace?.rawValue,
            mentalMuscleRaw: domain.mentalMuscle?.rawValue,
            responseToSetbackRaw: domain.responseToSetback?.rawValue,
            habitGoalRaw: domain.habitGoal?.rawValue,
            aiCoachToneRaw: domain.aiCoachTone?.rawValue,
            createdAt: domain.createdAt
        )
    }
}
