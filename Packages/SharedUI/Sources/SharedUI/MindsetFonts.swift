//
//  MindsetFonts.swift
//  SharedUI
//
//  Semantic font tokens for the Mindset Ritual app.
//  System fonts: New York (serif) for reflective content, SF Pro (sans) for UI.
//  Vibe: Positive, premium, focused, habit-forming.
//

import SwiftUI

public enum MindsetFonts {

    // MARK: - Display & Headlines (Serif — reflective, editorial)

    /// Hero headlines — Paywall, onboarding questions, major reveals
    public static let displayHeadline = Font.system(size: 28, weight: .medium, design: .serif)

    /// Large display — Ritual success, paywall title
    public static let displayLarge = Font.system(size: 34, weight: .bold, design: .serif)

    /// Button display — MindsetIconButton Font (Default)
    public static let mindsetIconButtonFont = Font.system(size: MindsetLayout.iconLarge)

    /// Button display — MindsetIconButton Font (Avatar)
    public static let mindsetAvatarIconButtonFont = Font.system(size: MindsetLayout.avatarIconSize)

    /// Prompt headlines — "The Optimism Bridge", ritual step titles
    public static let promptHeadline = Font.system(.headline, design: .serif).weight(.medium)

    // MARK: - Body (Sans — clear, modern)

    /// Main body text
    public static let body = Font.body

    /// Reflective question text
    public static let promptQuestion = Font.body

    /// Body with medium weight — option buttons, selectable text
    public static let bodyMedium = Font.body.weight(.medium)

    /// Slightly smaller body
    public static let subheadline = Font.subheadline

    /// Small body / footnotes
    public static let footnote = Font.footnote

    /// Callout size
    public static let callout = Font.callout

    // MARK: - Labels & Metadata (Sans)

    /// Section headers — Settings, profile groups
    public static let sectionHeader = Font.subheadline.weight(.semibold)

    /// Category labels — "BEST POSSIBLE SELF", "CURRENT GOAL"
    public static let label = Font.caption2.weight(.black)

    /// Section labels with tracking
    public static let labelUppercase = Font.caption2.weight(.bold)

    /// Secondary captions
    public static let caption = Font.caption

    /// Caption with bold
    public static let captionBold = Font.caption.weight(.bold)

    // MARK: - UI Elements

    /// Primary button text
    public static let button = Font.headline

    /// Sign In Button default Font
    public static let buttonSignIn = Font.title2.weight(.medium)

    /// Feature row titles
    public static let featureTitle = Font.title3

    /// Icon sizing (e.g. close button)
    public static let title2 = Font.title2

    /// Navigation / screen titles
    public static let screenTitle = Font.largeTitle.weight(.bold)

    /// Stat values
    public static let statValue = Font.headline
    
    public static let debugFont: Font = .system(size: 10, weight: .regular, design: .monospaced)
    
}
