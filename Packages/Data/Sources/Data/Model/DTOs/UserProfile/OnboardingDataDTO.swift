//
//  OnboardingDataDTO.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//

import Domain

/// A Codable container for onboarding responses, used to configure AI coaching parameters.
public struct OnboardingDataDTO: Codable {

    // MARK: - Quiz Results (MLP Configuration)
    public let headspace: String?
    public let targetEmotion: String?
    public let responseToSetback: String?
    public let planningStyle: String?
    public let aiCoachTone: String?

    /// Maps the Domain ``OnboardingData`` to a DTO for Firebase storage.
    public init(from domain: OnboardingData) {
        // We store the rawValue (String) to ensure Firestore compatibility
        self.headspace = domain.headspace?.rawValue
        self.targetEmotion = domain.targetEmotion?.rawValue
        self.responseToSetback = domain.responseToSetback?.rawValue
        self.planningStyle = domain.planningStyle?.rawValue
        self.aiCoachTone = domain.aiCoachTone?.rawValue
    }

    /// Converts the DTO back into the Domain ``OnboardingData``.
    public func toDomain() -> OnboardingData {
        OnboardingData(
            headspace: OnboardingData.Headspace(rawValue: headspace ?? ""),
            targetEmotion: OnboardingData.TargetEmotion(rawValue: targetEmotion ?? ""),
            responseToSetback: OnboardingData.ResponseToSetback(rawValue: responseToSetback ?? ""),
            planningStyle: OnboardingData.PlanningStyle(rawValue: planningStyle ?? ""),
            aiCoachTone: OnboardingData.AICoachTone(rawValue: aiCoachTone ?? "")
        )
    }
}
