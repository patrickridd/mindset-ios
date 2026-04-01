//
//  PromptDefinition.swift
//  Domain
//

public enum PromptDefinition: String, Codable, CaseIterable, Hashable, Sendable {
    
    public var id: PromptID {
        rawValue
    }

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

    public var slots: Int {
        switch self {
        case .todoToday, .gratitude:
            return 3
        default:
            return 1
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

    public var prompt: Prompt {
        let content: (headline: String, question: String, tip: String, rationale: String)
        switch self {
        case .gratitude:
            content = (
                headline: "Grateful feelings",
                question: "What are 3 things that make you 'feel' grateful?",
                tip: "Name the feeling each one evokes—warmth, relief, joy—not just the object.",
                rationale: "Affect-focused gratitude strengthens emotional granularity and well-being.",
            )
        case .todoToday:
            content = (
                headline: "Today's priorities",
                question: "What are your top 3 things to get done today?",
                tip:  "Be specific enough that you'd know if each item were done by tonight.",
                rationale: "Clear daily intentions improve follow-through and reduce cognitive load.",
            )
        case .feel:
            content = (
                headline:  "Today's intention",
                question: "How do you want to feel today and how could you accomplish that?",
                tip: "Link one concrete action to the emotional state you want.",
                rationale: "Aligning behavior with desired affect supports self-regulation and mood.",
            )
        case .kindness01:
            content = (
                headline: "The Kindness Booster",
                question: "What is one small, unexpected act of kindness you could perform for someone today?",
                tip: "Research shows that 'clumping' five acts into one day creates a much higher happiness spike than spreading them out.",
                rationale: "Activates the pro-social happiness pathway (Lyubomirsky, 2005)."
            )
        case .savoring01:
            content = (
                headline: "Present-Moment Savoring",
                question: "Identify one positive experience happening 'right now'. How can you intensify the joy of it?",
                tip: "Try 'behavioral expression'—smile, take a deep breath, or tell someone nearby how much you're enjoying this.",
                rationale: "Strengthens the ability to extract pleasure from everyday experiences (Bryant & Veroff)."
            )
        case .bestPossibleSelf01:
            content = (
                headline: "The Optimism Bridge",
                question: "Imagine yourself 5 years from now where everything has gone as well as possible. What is that version of you doing today?",
                tip: "Don't worry about the 'how' yet. Focus on the feeling of self-efficacy and reaching your goals.",
                rationale: "Linked to significant increases in optimism and health (King, 2001)."
            )
        case .signatureStrength01:
            content = (
                headline: "Strength Deployment",
                question: "Which of your core strengths (e.g., Curiosity, Bravery, Humor) can you use in a 'new way' today?",
                tip: "Pick one strength and apply it to a task you usually find boring or difficult.",
                rationale: "Using signature strengths in new ways is proven to boost happiness for up to 6 months (Seligman)."
            )
        case .mementoMori01:
            content = (
                headline: "The Perspective Reset",
                question: "If this were the final week of your life, what would you stop worrying about immediately?",
                tip: "This isn't meant to be morbid; it's a tool to cut through the 'noise' and find your true signals.",
                rationale: "Reduces anxiety over trivialities and clarifies life values."
            )
        case .gratitude01:
            content = (
                headline: "The Gratitude Scan",
                question: "What are three small things that went well in the last 24 hours?",
                tip: "Specificity is key. Instead of 'family', think 'the way my son laughed at breakfast'.",
                rationale: "Scanning for the positive rewires the brain's default mode network."
            )
        case .stoic01:
            content = (
                headline: "The Circle of Control",
                question: "What is one thing you are currently worried about that is actually outside of your control?",
                tip: "Acknowledge the worry, then consciously decide to put your energy into an action you 'can' control.",
                rationale: "Reduces anxiety by narrowing focus to self-agency."
            )
        case .futureSelf01:
            content = (
                headline: "The Intention Bridge",
                question: "If you could only accomplish one thing today to feel proud of yourself, what would it be?",
                tip: "Choose the 'frog'—the task you're most likely to procrastinate on.",
                rationale: "Increases self-efficacy and goal attainment through mental contrasting."
            )
        }
        return Prompt(id: id, category: category, headline: content.headline, questionText: content.question, coachTip: content.tip, scientificRationale: content.rationale, responseSlotCount: slots)
    }
}
