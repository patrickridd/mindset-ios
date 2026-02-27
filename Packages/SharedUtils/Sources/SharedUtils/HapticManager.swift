//
//  HapticManager.swift
//  SharedUtils
//
//  Standardized haptics for the app. Use the semantic APIs below for consistency.
//

import UIKit

@MainActor
public enum HapticManager {

    // Keep a single instance to avoid re-initialization overhead during loops
    private static let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Semantic APIs (prefer these)

    /// Call this before starting a typewriter animation to "warm up" the engine
    public static func prepareTypewriter() {
        softGenerator.prepare()
        lightGenerator.prepare()
    }

    /// Use for AI character/word streaming. Uses .soft to prevent "haptic noise."
    public static func typewriterTick() {
        softGenerator.impactOccurred()
        // We re-prepare immediately so the next tap is ready to go
        softGenerator.prepare()
    }

    /// Use for significant punctuation in a stream (ends of sentences).
    public static func typewriterEmphasis() {
        lightGenerator.impactOccurred()
        lightGenerator.prepare()
    }

    /// Use when the user selects one option from a set (e.g. onboarding choice, list row, segment).
    public static func selection() {
        impact(.light)
    }

    /// Use when the user performs a primary action (e.g. submit, continue, complete step).
    public static func action() {
        impact(.medium)
    }

    /// Use when a flow or task completes successfully (e.g. ritual done, onboarding done).
    public static func success() {
        notification(.success)
    }

    /// Use for repeated feedback (e.g. progress bar tick, XP gain tick).
    public static func tick() {
        impact(.soft)
    }

    // MARK: - Low-level APIs (use only when semantic APIs don’t fit)

    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        // Optimization: Prepare the generator to reduce latency during fast typing
        generator.prepare()
        generator.impactOccurred()
    }

    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
