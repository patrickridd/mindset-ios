//
//  AppRitualGenerator.swift
//  Domain
//
//  Created by patrick ridd on 4/13/26.
//


public final class AppRitualGenerator: RitualGenerator {
    public init() {}

    public func generateSession(for type: PromptType, user: User, history: [Entry]) -> RitualSession {
        let recentPromptIds = Set(history.prefix(10).flatMap { $0.promptResponses.map { $0.promptId } })
        let allAvailable = MindsetPrompt.allCases.filter { $0.type == type }
        let planningStyle = user.onboardingData.planningStyle ?? .flexible
        
        // --- 1. The Anchor (Gratitude) ---
        // Always starts the session to build momentum.
        var ritualSteps: [Prompt] = []
        let anchors = allAvailable.filter { $0.category == .gratitude }
        if let anchor = anchors.filter({ !recentPromptIds.contains($0.id) }).shuffled().first ?? anchors.randomElement() {
            ritualSteps.append(anchor)
        }
        
        // --- 2. The Weighted Variety (Personalization) ---
        // This uses the score() to pick the best "Middle" prompts for their current Headspace/Emotion.
        let variables = allAvailable.filter { $0.category != .gratitude && $0.category != .futureSelf }
        let sortedVariables = variables.shuffled().sorted { score($0, for: user) > score($1, for: user) }
        let freshVariety = sortedVariables.filter { !recentPromptIds.contains($0.id) }
        ritualSteps.append(contentsOf: freshVariety.prefix(2).map { $0 as Prompt })
        
        // --- 3. The Closer (The "Intention Bridge" Logic) ---
        let closers = allAvailable.filter { $0.category == .futureSelf }
        
        // Determine if we should show Goal Setting based on preference and time of day
        let shouldShowGoalSetting: Bool
        switch planningStyle {
        case .morning:
            shouldShowGoalSetting = (type == .morning)
        case .evening:
            shouldShowGoalSetting = (type == .evening)
        case .flexible:
            // STRATEGY: Show it in the Morning by default,
            // but if they skip it or stop using it, we could pivot.
            shouldShowGoalSetting = (type == .morning)
        }
        
        if shouldShowGoalSetting {
            if let closer = closers.filter({ !recentPromptIds.contains($0.id) }).shuffled().first ?? closers.randomElement() {
                ritualSteps.append(closer)
            }
        }
        
        return RitualSession(
            title: "\(type.rawValue.capitalized) Mindset",
            type: type,
            prompts: ritualSteps
        )
    }

    private func score(_ prompt: MindsetPrompt, for user: User) -> Int {
        var score = 0
        let data = user.onboardingData
        
        // --- Q1: Headspace (Difficulty & Complexity) ---
        // Focuses on the "Volume" of the user's mental noise.
        switch data.headspace {
        case .overwhelmed, .restless:
            // High noise: prioritize grounding, simple Stoic logic, and savoring.
            if prompt.category == .stoic || prompt.category == .savoring { score += 20 }
        case .focused, .content:
            // Low noise: prioritize "Deep Work" reflections and Memento Mori.
            if prompt.category == .mementoMori || prompt.category == .signatureStrength { score += 10 }
        case .none: break
        }

        // --- Q2: Target Emotion (The "Pain Point") ---
        // This drives the Insight Engine by addressing the user's specific struggle.
        if let emotion = data.targetEmotion {
            switch emotion {
            case .anxiety:
                // Anxiety needs Stoic control circles and grounding.
                if prompt.category == .stoic || prompt.category == .savoring { score += 25 }
            case .focus:
                // Lack of focus needs goal alignment and signature strengths.
                if prompt.category == .futureSelf || prompt.category == .signatureStrength { score += 25 }
            case .selfDoubt:
                // Self-doubt needs Best Possible Self and Strengths.
                if prompt.category == .bestPossibleSelf || prompt.category == .signatureStrength { score += 25 }
            case .frustration:
                // Anger/Frustration needs perspective shifts (Memento Mori).
                if prompt.category == .mementoMori || prompt.category == .stoic { score += 25 }
            }
        }

        // --- Q3: Response to Setback (CBT/Stoic Diagnostic) ---
        // Corrective logic for the user's "Default Failure Mode."
        if let setbackResponse = data.responseToSetback {
            switch setbackResponse {
            case .blameMyself, .getStuck:
                // Needs Cognitive Reappraisal to get moving again.
                if prompt.category == .stoic || prompt.category == .savoring { score += 20 }
            case .fixIt:
                // Needs to ensure they are fixing the *right* things.
                if prompt.category == .futureSelf || prompt.category == .signatureStrength { score += 10 }
            case .blameOthers:
                // Needs a reminder of personal agency and mortality.
                if prompt.category == .mementoMori || prompt.category == .stoic { score += 20 }
            }
        }
        
        // --- Q4: Planning Style (The Intention Bridge) ---
        // Ensures "Action" prompts appear when the user is actually ready to plan.
        if let style = data.planningStyle {
            switch style {
            case .morning, .evening:
                // If they have a dedicated planning time, prioritize the "Future Self" (Intentions) category.
                if prompt.category == .futureSelf { score += 15 }
            case .flexible:
                // If they are unsure, keep the "Future Self" prompts at a lower priority to avoid pressure.
                if prompt.category == .futureSelf { score -= 5 }
            }
        }
        
        // Note: Q5 (AICoachTone) is handled in the AIAnalysisService, not prompt selection.
        
        return score
    }
}
