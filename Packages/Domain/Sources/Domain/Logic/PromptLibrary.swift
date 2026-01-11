//
//  PromptLibrary.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public struct PromptLibrary {
    public static let allPrompts: [PromptCategory: [MindsetPrompt]] = [
        .kindness: [
            MindsetPrompt(
                id: "kindness_01",
                category: .kindness,
                headline: "The Kindness Booster",
                questionText: "What is one small, unexpected act of kindness you could perform for someone today?",
                coachTip: "Research shows that 'clumping' five acts into one day creates a much higher happiness spike than spreading them out.",
                scientificRationale: "Activates the pro-social happiness pathway (Lyubomirsky, 2005)."
            )
        ],
        .savoring: [
            MindsetPrompt(
                id: "savoring_01",
                category: .savoring,
                headline: "Present-Moment Savoring",
                questionText: "Identify one positive experience happening *right now*. How can you intensify the joy of it?",
                coachTip: "Try 'behavioral expression'—smile, take a deep breath, or tell someone nearby how much you're enjoying this.",
                scientificRationale: "Strengthens the ability to extract pleasure from everyday experiences (Bryant & Veroff)."
            )
        ],
        .bestPossibleSelf: [
            MindsetPrompt(
                id: "bps_01",
                category: .bestPossibleSelf,
                headline: "The Optimism Bridge",
                questionText: "Imagine yourself 5 years from now where everything has gone as well as possible. What is that version of you doing today?",
                coachTip: "Don't worry about the 'how' yet. Focus on the feeling of self-efficacy and reaching your goals.",
                scientificRationale: "Linked to significant increases in optimism and health (King, 2001)."
            )
        ],
        .signatureStrength: [
            MindsetPrompt(
                id: "strength_01",
                category: .signatureStrength,
                headline: "Strength Deployment",
                questionText: "Which of your core strengths (e.g., Curiosity, Bravery, Humor) can you use in a *new way* today?",
                coachTip: "Pick one strength and apply it to a task you usually find boring or difficult.",
                scientificRationale: "Using signature strengths in new ways is proven to boost happiness for up to 6 months (Seligman)."
            )
        ],
        .mementoMori: [
            MindsetPrompt(
                id: "memento_01",
                category: .mementoMori,
                headline: "The Perspective Reset",
                questionText: "If this were the final week of your life, what would you stop worrying about immediately?",
                coachTip: "This isn't meant to be morbid; it's a tool to cut through the 'noise' and find your true signals.",
                scientificRationale: "Reduces anxiety over trivialities and clarifies life values."
            )
        ]
    ]
}
