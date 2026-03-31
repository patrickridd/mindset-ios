//
//  PromptLibrary.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public struct PromptLibrary {
    /// Default morning ritual: gratitude (3 slots), priorities (3 slots), intention (1 slot).
    public static let morningStartTemplate: [Prompt] = [
        Prompt(
            id: "template_grateful",
            category: .gratitude,
            headline: "Grateful feelings",
            questionText: "What are 3 things that make you 'feel' grateful?",
            coachTip:
                "Name the feeling each one evokes—warmth, relief, joy—not just the object.",
            scientificRationale:
                "Affect-focused gratitude strengthens emotional granularity and well-being.",
            responseSlotCount: 3
        ),
        Prompt(
            id: "template_todos",
            category: .futureSelf,
            headline: "Today's priorities",
            questionText: "What are your top 3 things to get done today?",
            coachTip: "Be specific enough that you'd know if each item were done by tonight.",
            scientificRationale:
                "Clear daily intentions improve follow-through and reduce cognitive load.",
            responseSlotCount: 3
        ),
        Prompt(
            id: "template_feel",
            category: .futureSelf,
            headline: "Today's intention",
            questionText: "How do you want to feel today and how could you accomplish that?",
            coachTip: "Link one concrete action to the emotional state you want.",
            scientificRationale:
                "Aligning behavior with desired affect supports self-regulation and mood.",
            responseSlotCount: 1
        ),
    ]

    public static let allPrompts: [PromptCategory: [Prompt]] = [
        .kindness: [
            Prompt(
                id: "kindness_01",
                category: .kindness,
                headline: "The Kindness Booster",
                questionText:
                    "What is one small, unexpected act of kindness you could perform for someone today?",
                coachTip:
                    "Research shows that 'clumping' five acts into one day creates a much higher happiness spike than spreading them out.",
                scientificRationale:
                    "Activates the pro-social happiness pathway (Lyubomirsky, 2005)."
            )
        ],
        .savoring: [
            Prompt(
                id: "savoring_01",
                category: .savoring,
                headline: "Present-Moment Savoring",
                questionText:
                    "Identify one positive experience happening 'right now'. How can you intensify the joy of it?",
                coachTip:
                    "Try 'behavioral expression'—smile, take a deep breath, or tell someone nearby how much you're enjoying this.",
                scientificRationale:
                    "Strengthens the ability to extract pleasure from everyday experiences (Bryant & Veroff)."
            )
        ],
        .bestPossibleSelf: [
            Prompt(
                id: "bps_01",
                category: .bestPossibleSelf,
                headline: "The Optimism Bridge",
                questionText:
                    "Imagine yourself 5 years from now where everything has gone as well as possible. What is that version of you doing today?",
                coachTip:
                    "Don't worry about the 'how' yet. Focus on the feeling of self-efficacy and reaching your goals.",
                scientificRationale:
                    "Linked to significant increases in optimism and health (King, 2001)."
            )
        ],
        .signatureStrength: [
            Prompt(
                id: "strength_01",
                category: .signatureStrength,
                headline: "Strength Deployment",
                questionText:
                    "Which of your core strengths (e.g., Curiosity, Bravery, Humor) can you use in a 'new way' today?",
                coachTip:
                    "Pick one strength and apply it to a task you usually find boring or difficult.",
                scientificRationale:
                    "Using signature strengths in new ways is proven to boost happiness for up to 6 months (Seligman)."
            )
        ],
        .mementoMori: [
            Prompt(
                id: "memento_01",
                category: .mementoMori,
                headline: "The Perspective Reset",
                questionText:
                    "If this were the final week of your life, what would you stop worrying about immediately?",
                coachTip:
                    "This isn't meant to be morbid; it's a tool to cut through the 'noise' and find your true signals.",
                scientificRationale: "Reduces anxiety over trivialities and clarifies life values."
            )
        ],
        .gratitude: [
            Prompt(
                id: "gratitude_01",
                category: .gratitude,
                headline: "The Gratitude Scan",
                questionText: "What are three small things that went well in the last 24 hours?",
                coachTip:
                    "Specificity is key. Instead of 'family', think 'the way my son laughed at breakfast'.",
                scientificRationale:
                    "Scanning for the positive rewires the brain's default mode network."
            )
        ],
        .stoic: [
            Prompt(
                id: "stoic_01",
                category: .stoic,
                headline: "The Circle of Control",
                questionText:
                    "What is one thing you are currently worried about that is actually outside of your control?",
                coachTip:
                    "Acknowledge the worry, then consciously decide to put your energy into an action you 'can' control.",
                scientificRationale: "Reduces anxiety by narrowing focus to self-agency."
            )
        ],
        .futureSelf: [
            Prompt(
                id: "future_01",
                category: .futureSelf,
                headline: "The Intention Bridge",
                questionText:
                    "If you could only accomplish one thing today to feel proud of yourself, what would it be?",
                coachTip: "Choose the 'frog'—the task you're most likely to procrastinate on.",
                scientificRationale:
                    "Increases self-efficacy and goal attainment through mental contrasting."
            )
        ],
    ]
}
