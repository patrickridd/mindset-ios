//
//  OnboardingDataDTO.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//

import Domain

/// A Codable container for onboarding responses, used to configure AI coaching parameters.
public struct OnboardingDataDTO: Codable {
    public let overwhelmFrequency: String
    public let primaryGoal: String
    
    // MARK: - Quiz Results (MLP Configuration)
    public let headspace: String?
    public let mentalMuscle: String?
    public let responseToSetback: String?
    public let habitGoal: String?
    public let aiCoachTone: String?

    /// Maps the Domain ``OnboardingData`` to a DTO for Firebase storage.
    public init(from domain: OnboardingData) {
        self.overwhelmFrequency = domain.overwhelmFrequency
        self.primaryGoal = domain.primaryGoal
        
        // We store the rawValue (String) to ensure Firestore compatibility
        self.headspace = domain.headspace?.rawValue
        self.mentalMuscle = domain.mentalMuscle?.rawValue
        self.responseToSetback = domain.responseToSetback?.rawValue
        self.habitGoal = domain.habitGoal?.rawValue
        self.aiCoachTone = domain.aiCoachTone?.rawValue
    }

    /// Converts the DTO back into the Domain ``OnboardingData``.
    public func toDomain() -> OnboardingData {
        OnboardingData(
            overwhelmFrequency: overwhelmFrequency,
            primaryGoal: primaryGoal,
            headspace: OnboardingData.Headspace(rawValue: headspace ?? ""),
            mentalMuscle: OnboardingData.MentalMuscle(rawValue: mentalMuscle ?? ""),
            responseToSetback: OnboardingData.ResponseToSetback(rawValue: responseToSetback ?? ""),
            habitGoal: OnboardingData.HabitGoal(rawValue: habitGoal ?? ""),
            aiCoachTone: OnboardingData.AICoachTone(rawValue: aiCoachTone ?? "")
        )
    }
}
