//
//  OnboardingData.swift
//  Domain
//
//  Created by patrick ridd on 1/7/26.
//

public struct OnboardingData: Sendable {
    public var overwhelmFrequency: String = ""

    // MARK: - Onboarding Quiz Results (MLP)

    /// Q1: Sets prompt difficulty
    public var headspace: Headspace?
    /// Q2: Weights archetype (Stoic vs. Positive Psych)
    public var mentalMuscle: MentalMuscle?
    /// Q3: CBT vs. Stoic intervention needs
    public var responseToSetback: ResponseToSetback?
    /// Q4: Overall Mindset Goal
    public var mindsetGoal: MindsetGoal?
    /// Q5: AI feedback system prompt tone
    public var aiCoachTone: AICoachTone?

    public init(overwhelmFrequency: String, headspace: Headspace? = nil, mentalMuscle: MentalMuscle? = nil, responseToSetback: ResponseToSetback? = nil, mindsetGoal: MindsetGoal? = nil, aiCoachTone: AICoachTone? = nil) {
        self.overwhelmFrequency = overwhelmFrequency
        self.headspace = headspace
        self.mentalMuscle = mentalMuscle
        self.responseToSetback = responseToSetback
        self.mindsetGoal = mindsetGoal
        self.aiCoachTone = aiCoachTone
    }

    public init(overwhelmFrequency: String = "") {
        self.overwhelmFrequency = overwhelmFrequency
    }
    
    public enum OverwhelmedFrequency: String, Codable, CaseIterable, Sendable {
        case rarely = "Rarely"
        case sometimes = "Sometimes"
        case often = "Often"
        case always = "Always"
    }

    // MARK: - Onboarding Enums

    /// Q1: Difficulty of prompts
    public enum Headspace: String, Codable, CaseIterable, Sendable {
        case restless = "Restless"
        case focused = "Focused"
        case overwhelmed = "Overwhelmed"
        case content = "Content"
    }

    /// Q2: Archetype weighting (Stoic vs. Positive Psych)
    public enum MentalMuscle: String, Codable, CaseIterable, Sendable {
        case resilience = "Resilience"
        case gratitude = "Gratitude"
        case purpose = "Purpose"
        case calm = "Calm"
    }

    /// Q3: CBT vs. Stoic intervention needs
    public enum ResponseToSetback: String, Codable, CaseIterable, Sendable {
        case blameMyself = "Blame myself"
        case fixIt = "Fix it"
        case getStuck = "Get stuck"
        case blameOthers = "Blame others"
    }

    /// Q4: Mindset Current Goal
    public enum MindsetGoal: String, Codable, CaseIterable, Sendable {
        case happier = "Happier"
        case resilient = "Resilience"
        case purpose = "Purpose"
        case balanced = "Balanced"
    }

    /// Q5: AI feedback tone
    public enum AICoachTone: String, Codable, CaseIterable, Sendable {
        case sageReflective = "The Sage (Reflective)"
        case cheerleaderWarm = "The Cheerleader (Warm)"
        case therapistEmpathetic = "The Therapist (Empathetic & Insightful)"
        case friendCasual = "The Friend (Casual)"
    }
}
