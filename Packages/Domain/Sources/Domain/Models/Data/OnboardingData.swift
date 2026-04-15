//
//  OnboardingData.swift
//  Domain
//
//  Created by patrick ridd on 1/7/26.
//

import Foundation

/// A 1:1 mapping of the 5-question onboarding quiz used to personalize the user experience.
///
/// This data informs the ``RitualGenerator`` on which psychological frameworks to prioritize
/// and sets the baseline for the "Personalized Insight Engine."
public struct OnboardingData: Codable, Sendable {
    
    // MARK: - Properties (Logic Mappings)
    
    /// Q1: The user's current mental state.
    public var headspace: Headspace?
    
    /// Q2: Specific emotional targets for the Insight Engine.
    public var targetEmotion: TargetEmotion?
    
    /// Q3: Instinctive reaction to adversity (CBT/Stoic Diagnostic).
    public var responseToSetback: ResponseToSetback?
    
    /// Q4: Preferred timing for goal setting (The "Intention Bridge").
    public var planningStyle: PlanningStyle?
    
    /// Q5: Persona used for AI-generated feedback.
    public var aiCoachTone: AICoachTone?

    // MARK: - Initializer

    public init(
        headspace: Headspace? = nil,
        targetEmotion: TargetEmotion? = nil,
        responseToSetback: ResponseToSetback? = nil,
        planningStyle: PlanningStyle? = nil,
        aiCoachTone: AICoachTone? = nil
    ) {
        self.headspace = headspace
        self.targetEmotion = targetEmotion
        self.responseToSetback = responseToSetback
        self.planningStyle = planningStyle
        self.aiCoachTone = aiCoachTone
    }

    // MARK: - Nested Enums

    /// Q1: Headspace Logic
    public enum Headspace: String, Codable, CaseIterable, Sendable {
        case restless = "Restless"
        case focused = "Focused"
        case overwhelmed = "Overwhelmed"
        case content = "Content"
    }

    /// Q2: Target Emotion Logic
    public enum TargetEmotion: String, Codable, CaseIterable, Sendable {
        case anxiety = "Anxiety & Stress"
        case focus = "Lack of Focus"
        case selfDoubt = "Self-Doubt"
        case frustration = "Anger/Frustration"
    }

    /// Q3: Response to Setback Logic
    public enum ResponseToSetback: String, Codable, CaseIterable, Sendable {
        case blameMyself = "Blame myself"
        case fixIt = "Fix it"
        case getStuck = "Get stuck"
        case blameOthers = "Blame others"
    }

    /// Q4: Planning Style Logic
    public enum PlanningStyle: String, Codable, CaseIterable, Sendable {
        case morning = "First thing in the morning"
        case evening = "Last thing before bed"
        case flexible = "I'm not sure yet"
    }

    /// Q5: AI Coach Tone Logic
    public enum AICoachTone: String, Codable, CaseIterable, Sendable {
        case sageReflective = "The Sage (Reflective)"
        case cheerleaderWarm = "The Cheerleader (Warm)"
        case therapistEmpathetic = "The Therapist (Insightful)"
        case friendCasual = "The Friend (Casual)"
    }
}
