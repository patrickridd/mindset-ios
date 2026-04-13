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
        
        let anchors = allAvailable.filter { $0.category == .gratitude }
        let variables = allAvailable.filter { $0.category != .gratitude && $0.category != .futureSelf }
        let closers = allAvailable.filter { $0.category == .futureSelf }

        var ritualSteps: [Prompt] = []

        // 1. The Anchor (Gratitude)
        if let anchor = anchors.filter({ !recentPromptIds.contains($0.id) }).shuffled().first ?? anchors.randomElement() {
            ritualSteps.append(anchor)
        }

        // 2. The Weighted Variety
        // We sort based on the new onboarding mapping
        let weightedVariables = variables.shuffled().sorted { p1, p2 in
            score(p1, for: user) > score(p2, for: user)
        }
        
        let freshVariety = weightedVariables.filter { !recentPromptIds.contains($0.id) }
        ritualSteps.append(contentsOf: freshVariety.prefix(2).map { $0 as Prompt })
        // 3. The Closer (Intention)
        if let closer = closers.filter({ !recentPromptIds.contains($0.id) }).shuffled().first ?? closers.randomElement() {
            ritualSteps.append(closer)
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

        // --- Q1: Headspace (Difficulty/Focus) ---
        switch data.headspace {
        case .overwhelmed, .restless:
            // High anxiety/stress: prioritize grounding and control
            if prompt.category == .stoic || prompt.category == .savoring { score += 20 }
        case .focused, .content:
            // High clarity: prioritize deeper reflective work
            if prompt.category == .mementoMori || prompt.category == .signatureStrength { score += 10 }
        case .none: break
        }

        // --- Q2: Mental Muscle (The "Archetype" weighting) ---
        if let muscle = data.mentalMuscle {
            switch muscle {
            case .resilience: if prompt.category == .stoic { score += 15 }
            case .gratitude: if prompt.category == .gratitude { score += 15 }
            case .purpose: if prompt.category == .bestPossibleSelf { score += 15 }
            case .calm: if prompt.category == .savoring { score += 15 }
            }
        }

        // --- Q3: Response to Setback (CBT vs Stoic needs) ---
        if let setbackResponse = data.responseToSetback {
            switch setbackResponse {
            case .blameMyself, .getStuck:
                // Needs Cognitive Reappraisal / Reframing
                if prompt.category == .stoic || prompt.category == .savoring { score += 20 }
            case .fixIt:
                // Already action-oriented: give them purpose/strengths
                if prompt.category == .signatureStrength { score += 10 }
            case .blameOthers:
                // Needs Perspective Shifts
                if prompt.category == .mementoMori { score += 15 }
            }
        }

        // --- Q4: Mindset Goal ---
        if let goal = data.mindsetGoal {
            switch goal {
            case .happier: if prompt.category == .gratitude || prompt.category == .savoring { score += 10 }
            case .resilient: if prompt.category == .stoic || prompt.category == .mementoMori { score += 10 }
            case .purpose: if prompt.category == .bestPossibleSelf || prompt.category == .signatureStrength { score += 10 }
            case .balanced: if prompt.category == .savoring || prompt.category == .stoic { score += 10 }
            }
        }

        return score
    }
}
