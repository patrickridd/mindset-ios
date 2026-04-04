//
//  PromptDefinition.swift
//  Domain
//

public enum PromptType: String, Prompt, Codable, CaseIterable, Hashable, Sendable {

    public var id: String { rawValue }

    case gratitude
    case todoToday
    case feel
    case kindness01
    case savoring01
    case bestPossibleSelf01
    case signatureStrength01
    case mementoMori01
    case gratitude01
    case stoic01
    case futureSelf01
    
    public var headline: String {
        switch self {
        case .gratitude:
            return "Grateful feelings"
        case .todoToday:
            return "Today's priorities"
        case .feel:
            return "Today's intention"
        case .kindness01:
            return "The Kindness Booster"
        case .savoring01:
            return "Present-Moment Savoring"
        case .bestPossibleSelf01:
            return "The Optimism Bridge"
        case .signatureStrength01:
            return "Strength Deployment"
        case .mementoMori01:
            return "The Perspective Reset"
        case .gratitude01:
            return "The Gratitude Scan"
        case .stoic01:
            return "The Circle of Control"
        case .futureSelf01:
            return "The Intention Bridge"
        }
    }

    public var questionText: String {
        switch self {
        case .gratitude:
            return "What are 3 things that make you 'feel' grateful?"
        case .todoToday:
            return "What are your top 3 things to get done today?"
        case .feel:
            return "How do you want to feel today and how could you accomplish that?"
        case .kindness01:
            return "What is one small, unexpected act of kindness you could perform for someone today?"
        case .savoring01:
            return "Identify one positive experience happening 'right now'. How can you intensify the joy of it?"
        case .bestPossibleSelf01:
            return "Imagine yourself 5 years from now where everything has gone as well as possible. What is that version of you doing today?"
        case .signatureStrength01:
            return "Which of your core strengths (e.g., Curiosity, Bravery, Humor) can you use in a 'new way' today?"
        case .mementoMori01:
            return "If this were the final week of your life, what would you stop worrying about immediately?"
        case .gratitude01:
            return "What are three small things that went well in the last 24 hours?"
        case .stoic01:
            return "What is one thing you are currently worried about that is actually outside of your control?"
        case .futureSelf01:
            return "If you could only accomplish one thing today to feel proud of yourself, what would it be?"
        }
    }

    public var coachTip: String {
        switch self {
        case .gratitude:
            return "Name the feeling each one evokes—warmth, relief, joy—not just the object."
        case .todoToday:
            return "Be specific enough that you'd know if each item were done by tonight."
        case .feel:
            return "Link one concrete action to the emotional state you want."
        case .kindness01:
            return "Research shows that 'clumping' five acts into one day creates a much higher happiness spike than spreading them out."
        case .savoring01:
            return "Try 'behavioral expression'—smile, take a deep breath, or tell someone nearby how much you're enjoying this."
        case .bestPossibleSelf01:
            return "Don't worry about the 'how' yet. Focus on the feeling of self-efficacy and reaching your goals."
        case .signatureStrength01:
            return "Pick one strength and apply it to a task you usually find boring or difficult."
        case .mementoMori01:
            return "This isn't meant to be morbid; it's a tool to cut through the 'noise' and find your true signals."
        case .gratitude01:
            return "Specificity is key. Instead of 'family', think 'the way my son laughed at breakfast'."
        case .stoic01:
            return "Acknowledge the worry, then consciously decide to put your energy into an action you 'can' control."
        case .futureSelf01:
            return "Choose the 'frog'—the task you're most likely to procrastinate on."
        }
    }

    public var scientificRationale: String {
        switch self {
        case .gratitude:
            return "Affect-focused gratitude strengthens emotional granularity and well-being."
        case .todoToday:
            return "Clear daily intentions improve follow-through and reduce cognitive load."
        case .feel:
            return "Aligning behavior with desired affect supports self-regulation and mood."
        case .kindness01:
            return "Activates the pro-social happiness pathway (Lyubomirsky, 2005)."
        case .savoring01:
            return "Strengthens the ability to extract pleasure from everyday experiences (Bryant & Veroff)."
        case .bestPossibleSelf01:
            return "Linked to significant increases in optimism and health (King, 2001)."
        case .signatureStrength01:
            return "Using signature strengths in new ways is proven to boost happiness for up to 6 months (Seligman)."
        case .mementoMori01:
            return "Reduces anxiety over trivialities and clarifies life values."
        case .gratitude01:
            return "Scanning for the positive rewires the brain's default mode network."
        case .stoic01:
            return "Reduces anxiety by narrowing focus to self-agency."
        case .futureSelf01:
            return "Increases self-efficacy and goal attainment through mental contrasting."
        }
    }

    public var responseSlotCount: Int {
        switch self {
        case .todoToday, .gratitude:
            return 3
        default:
            return 1
        }
    }

    public var category: PromptCategory {
        switch self {
        case .gratitude, .gratitude01:
            return .gratitude
        case .todoToday, .feel, .futureSelf01:
            return .futureSelf
        case .kindness01:
            return .kindness
        case .savoring01:
            return .savoring
        case .bestPossibleSelf01:
            return .bestPossibleSelf
        case .signatureStrength01:
            return .signatureStrength
        case .mementoMori01:
            return .mementoMori
        case .stoic01:
            return .stoic
        }
    }

    public var isMorningTemplate: Bool {
        switch self {
        case .gratitude, .todoToday, .feel:
            return true
        default:
            return false
        }
    }

}
