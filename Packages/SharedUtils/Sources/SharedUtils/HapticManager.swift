//
//  HapticManager.swift
//  SharedUtils
//
//  Standardized haptics for the app. Use the semantic APIs below for consistency.
//

import UIKit

@MainActor
public enum HapticManager {
    // MARK: - Semantic APIs (prefer these)

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

    /// Use for light repeated feedback (e.g. progress bar tick, XP gain tick).
    public static func tick() {
        impact(.light)
    }

    // MARK: - Low-level APIs (use only when semantic APIs don’t fit)

    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
