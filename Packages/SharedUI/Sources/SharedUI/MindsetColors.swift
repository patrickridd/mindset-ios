//
//  MindsetColors.swift
//  SharedUI
//
//  Semantic color tokens for the Mindset Ritual app.
//  Based on color psychology: calm (blue/green), motivation (orange), success (green).
//

import SwiftUI

public enum MindsetColors {

    // MARK: - Backgrounds

    /// Deep charcoal, warmer than pure black — used for dark backgrounds
    public static let backgroundDark = Color(red: 0.05, green: 0.05, blue: 0.06)

    /// Soft black for gradient end — subtle warmth
    public static let backgroundDarkSoft = Color(red: 0.08, green: 0.08, blue: 0.09)

    /// Warm accent for gradient — subtle amber tint
    public static let backgroundWarmAccent = Color(red: 0.12, green: 0.08, blue: 0.06)

    // MARK: - Text

    /// Primary text — off-white, warmer than pure white
    public static let textPrimary = Color(white: 0.96)

    /// Secondary text
    public static let textSecondary = Color.white.opacity(0.7)

    /// Tertiary / muted text
    public static let textMuted = Color.white.opacity(0.4)

    // MARK: - Accents & Motivation

    /// Primary accent — warm orange for motivation, CTAs, progress
    public static let accentOrange = Color.orange

    /// Softer orange for fills and subtle highlights
    public static let accentOrangeSoft = Color.orange.opacity(0.15)

    /// Coral gradient start — softer than pure orange
    public static let accentCoral = Color(red: 1.0, green: 0.55, blue: 0.35)

    // MARK: - Success & Calm

    /// Success green — growth, accomplishment, "what went well"
    public static let successGreen = Color(red: 0.21, green: 0.87, blue: 0.5)

    /// Calm teal — low-arousal positivity (optional for reflective screens)
    public static let calmTeal = Color(red: 0.3, green: 0.7, blue: 0.65)

    // MARK: - UI Elements

    /// Button border — unselected
    public static let borderSubtle = Color.white.opacity(0.2)

    /// Button border — accent (selected/hover)
    public static let borderAccent = Color.orange.opacity(0.5)

    /// Card/button fill — unselected
    public static let fillSubtle = Color.white.opacity(0.05)
}
