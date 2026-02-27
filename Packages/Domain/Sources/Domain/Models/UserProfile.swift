//
//  UserProfile.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

import Foundation

public struct UserProfile: Sendable {

    public let id: UUID
    public var userName: String
    public var primaryGoal: String
    public let createdAt: Date
    /// Legacy field; prefer `headspace` when available. Kept for migration.
    public var overwhelmedFrequency: OverwhelmedFrequency

    // MARK: - Onboarding Quiz Results (MLP)

    /// Q1: Sets prompt difficulty
    public var headspace: Headspace?
    /// Q2: Weights archetype (Stoic vs. Positive Psych)
    public var mentalMuscle: MentalMuscle?
    /// Q3: CBT vs. Stoic intervention needs
    public var responseToSetback: ResponseToSetback?
    /// Q4: Notification timing and XP goals
    public var habitGoal: HabitGoal?
    /// Q5: AI feedback system prompt tone
    public var aiCoachTone: AICoachTone?

    public init(
        id: UUID = UUID(),
        userName: String,
        primaryGoal: String,
        overwhelmedFrequency: OverwhelmedFrequency = .sometimes,
        headspace: Headspace? = nil,
        mentalMuscle: MentalMuscle? = nil,
        responseToSetback: ResponseToSetback? = nil,
        habitGoal: HabitGoal? = nil,
        aiCoachTone: AICoachTone? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userName = userName
        self.primaryGoal = primaryGoal
        self.overwhelmedFrequency = overwhelmedFrequency
        self.headspace = headspace
        self.mentalMuscle = mentalMuscle
        self.responseToSetback = responseToSetback
        self.habitGoal = habitGoal
        self.aiCoachTone = aiCoachTone
        self.createdAt = createdAt
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

    /// Q4: Notification timing and XP goals
    public enum HabitGoal: String, Codable, CaseIterable, Sendable {
        case consistency = "Consistency"
        case deepReflection = "Deep Reflection"
        case betterSleep = "Better Sleep"
    }

    /// Q5: AI feedback tone
    public enum AICoachTone: String, Codable, CaseIterable, Sendable {
        case sageReflective = "The Sage (Reflective)"
        case cheerleaderWarm = "The Cheerleader (Warm)"
        case therapistEmpathetic = "The Therapist (Empathetic & Insightful)"
        case friendCasual = "The Friend (Casual)"
    }
}
