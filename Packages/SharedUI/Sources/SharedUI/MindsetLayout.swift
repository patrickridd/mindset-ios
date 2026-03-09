//
//  MindsetLayout.swift
//  SharedUI
//
//  Semantic spacing, padding, and dimension tokens for the Mindset Ritual app.
//  Use these instead of magic numbers for consistent layout rhythm.
//

import SwiftUI

public enum MindsetLayout {

    // MARK: - Spacing (VStack/HStack spacing)

    public static let spacing4: CGFloat = 4
    public static let spacing5: CGFloat = 5
    public static let spacing6: CGFloat = 6
    public static let spacing8: CGFloat = 8
    public static let spacing10: CGFloat = 10
    public static let spacing12: CGFloat = 12
    public static let spacing15: CGFloat = 15
    public static let spacing16: CGFloat = 16
    public static let spacing20: CGFloat = 20
    public static let spacing24: CGFloat = 24
    public static let spacing25: CGFloat = 25
    public static let spacing30: CGFloat = 30
    public static let spacing40: CGFloat = 40

    // MARK: - Padding

    public static let paddingSmall: CGFloat = 8
    public static let paddingMedium: CGFloat = 12
    public static let paddingStandard: CGFloat = 16
    public static let paddingLarge: CGFloat = 20
    public static let paddingXLarge: CGFloat = 24
    public static let paddingCard: CGFloat = 25
    public static let paddingScreenHorizontal: CGFloat = 30

    // MARK: - Corner Radius

    public static let radiusSmall: CGFloat = 4
    public static let radiusMedium: CGFloat = 8
    public static let radiusStandard: CGFloat = 12
    public static let radiusButton: CGFloat = 14
    public static let radiusCard: CGFloat = 16
    public static let radiusCardLarge: CGFloat = 20
    public static let radiusIdentityCard: CGFloat = 24

    // MARK: - Dimensions

    public static let progressBarHeight: CGFloat = 8
    public static let buttonHeight: CGFloat = 60
    public static let iconExtraSmall: CGFloat = 8
    public static let iconSmall: CGFloat = 12
    public static let iconMedium: CGFloat = 16
    public static let iconLarge: CGFloat = 24
    public static let iconExtraLarge: CGFloat = 32
    public static let iconButtonLarge: CGFloat = 44
    public static let signInIconButton: CGFloat = 16

    /// Circular dismiss button (Reminders-style) — circle and icon size.
    public static let dismissButtonCircle: CGFloat = 30
    public static let heroCircleSize: CGFloat = 160
    public static let avatarSize: CGFloat = 100
    public static let avatarIconSize: CGFloat = 60
    public static let textEditorMinHeight: CGFloat = 120
    public static let bottomSpacerHeight: CGFloat = 20
    public static let spacerBottomMinLength: CGFloat = 50

    // MARK: - Line & Stroke

    public static let borderWidth: CGFloat = 1

    // MARK: - Shadow & Effects

    public static let shadowRadius: CGFloat = 5
    public static let shadowY: CGFloat = -5
    public static let glowBlurRadius: CGFloat = 20
    
    // MARK: - Detents
    
    public static let detentMinimum: CGFloat = 150
    public static let detentSmall: CGFloat = 300
}
