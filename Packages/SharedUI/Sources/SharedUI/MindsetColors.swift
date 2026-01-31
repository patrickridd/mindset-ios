//
//  MindsetColors.swift
//  SharedUI
//
//  Semantic color tokens for the Mindset Ritual app.
//  Based on color psychology: calm (blue/green), motivation (orange), success (green).
//

import SwiftUI
import UIKit

public enum MindsetColors {

    // MARK: - Backgrounds

    /// Deep charcoal, warmer than pure black — used for dark backgrounds
    public static let backgroundDark = Color(red: 0.05, green: 0.05, blue: 0.06)

    /// Soft black for gradient end — subtle warmth
    public static let backgroundDarkSoft = Color(red: 0.08, green: 0.08, blue: 0.09)

    /// Warm accent for gradient — subtle amber tint
    public static let backgroundWarmAccent = Color(red: 0.12, green: 0.08, blue: 0.06)

    /// Primary screen background — adapts to light/dark mode.
    /// Light: warm cream/ivory (positive, inviting). Dark: warm charcoal.
    public static let backgroundGrouped = Color(uiColor: .mindsetBackgroundGrouped)

    /// Elevated surface (cards, inputs) — adapts to light/dark mode.
    /// Light: warm white. Dark: elevated charcoal.
    public static let backgroundSecondary = Color(uiColor: .mindsetBackgroundSecondary)

    // MARK: - Text

    /// Primary text — off-white, warmer than pure white (for dark backgrounds)
    public static let textPrimary = Color(white: 0.96)

    /// Secondary text (for dark backgrounds)
    public static let textSecondary = Color.white.opacity(0.7)

    /// Tertiary / muted text (for dark backgrounds)
    public static let textMuted = Color.white.opacity(0.4)

    /// Primary text — adapts to light/dark mode. Use on adaptive backgrounds (e.g. backgroundGrouped).
    public static let textPrimaryAdaptive = Color(uiColor: .mindsetTextPrimaryAdaptive)

    /// Secondary text — adapts to light/dark mode. Use for supporting content.
    public static let textSecondaryAdaptive = Color(uiColor: .mindsetTextSecondaryAdaptive)

    /// Disabled/placeholder text — readable contrast in both modes.
    public static let textDisabled = Color(uiColor: .mindsetTextDisabled)

    /// Text on accent-colored buttons (e.g. Continue, primary CTAs) — dark gray for softer look.
    public static let textOnAccent = Color(uiColor: .mindsetTextOnAccent)

    /// Category/label accent — deeper orange for light mode contrast, same as accent in dark.
    public static let labelAccent = Color(uiColor: .mindsetLabelAccent)

    // MARK: - Accents & Motivation

    /// Primary accent — warm orange for motivation, CTAs, progress
    public static let accentOrange = Color.orange

    /// Softer orange for fills and subtle highlights
    public static let accentOrangeSoft = Color.orange.opacity(0.15)

    /// Coral gradient start — softer than pure orange
    public static let accentCoral = Color(red: 1.0, green: 0.55, blue: 0.35)

    // MARK: - Success & Growth

    /// Success green — bright, growth, accomplishment
    public static let successGreen = Color(red: 0.21, green: 0.87, blue: 0.5)

    /// Primary success — emerald, rich and premium (checkmarks, completion)
    public static let successEmerald = Color(red: 0.18, green: 0.65, blue: 0.46)

    /// Calm teal — low-arousal positivity (optional for reflective screens)
    public static let calmTeal = Color(red: 0.3, green: 0.7, blue: 0.65)

    // MARK: - Stoic Accent

    /// Slate — "Fortress" feel: borders, reflective content, memento mori
    public static let stoicSlate = Color(red: 0.4, green: 0.42, blue: 0.47)

    /// Softer slate for fills and subtle borders
    public static let stoicSlateSoft = Color(red: 0.4, green: 0.42, blue: 0.47).opacity(0.3)

    // MARK: - Achievement

    /// Gold — achievement, value, milestone moments (XP, badges)
    public static let achievementGold = Color(red: 0.78, green: 0.6, blue: 0.2)

    // MARK: - UI Elements

    /// Button border — unselected
    public static let borderSubtle = Color.white.opacity(0.2)

    /// Button border — accent (selected/hover)
    public static let borderAccent = Color.orange.opacity(0.5)

    /// Card/button fill — unselected
    public static let fillSubtle = Color.white.opacity(0.05)

    /// Progress bar — inactive segment
    public static let progressInactive = Color.gray.opacity(0.3)

    /// Disabled button background — readable contrast in both modes.
    public static let buttonDisabledBackground = Color(uiColor: .mindsetButtonDisabledBackground)
}

// MARK: - Adaptive UIKit Colors

private extension UIColor {
    static let mindsetBackgroundGrouped = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1)
        default:
            return UIColor(red: 0.97, green: 0.96, blue: 0.94, alpha: 1)
        }
    }

    static let mindsetBackgroundSecondary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
        default:
            return UIColor(red: 1.0, green: 0.995, blue: 0.97, alpha: 1)
        }
    }

    static let mindsetTextPrimaryAdaptive = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(white: 0.96, alpha: 1)
        default:
            return UIColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1)
        }
    }

    static let mindsetTextSecondaryAdaptive = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(white: 0.65, alpha: 1)
        default:
            return UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
        }
    }

    static let mindsetTextDisabled = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(white: 0.45, alpha: 1)
        default:
            return UIColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1)
        }
    }

    /// Text on accent buttons (e.g. Continue) — dark gray for softer look on orange
    static let mindsetTextOnAccent = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(white: 0.1, alpha: 1)
        default:
            return UIColor(red: 0.22, green: 0.2, blue: 0.18, alpha: 1)
        }
    }

    static let mindsetLabelAccent = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.orange
        default:
            return UIColor(red: 0.85, green: 0.42, blue: 0.12, alpha: 1)
        }
    }

    static let mindsetButtonDisabledBackground = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1)
        default:
            return UIColor(red: 0.88, green: 0.87, blue: 0.85, alpha: 1)
        }
    }
}
