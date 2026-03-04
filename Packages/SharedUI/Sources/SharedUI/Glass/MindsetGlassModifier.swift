//
//  MindsetGlassModifier.swift
//  SharedUI
//
//  Created by patrick ridd on 3/1/26.
//

import SwiftUI

public struct MindsetGlassModifier: ViewModifier {
    let style: MindsetGlassStyle
    let radius: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    public func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            // In iOS 26, the modifier takes a 'Glass' configuration
            content.glassEffect(
                glassConfiguration.tint(glassTint).interactive(isInteractive),
                in: .rect(cornerRadius: radius)
            )
        } else {
            // Legacy Fallback
            content.background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(fallbackColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(fallbackStroke, lineWidth: MindsetLayout.borderWidth)
                    )
            )
        }
    }
    
    // MARK: - Logic
    
    private var isInteractive: Bool {
        if case .card = style { return false }
        return true
    }
    
    // The 'Glass' struct is the 2026 equivalent of 'Material'
    @available(iOS 26.0, *)
    private var glassConfiguration: Glass {
        switch style {
        case .card: return .regular
        case .button: return .regular
        case .destructive: return .regular
        }
    }
    
    private var glassTint: Color {
        switch style {
        case .card:
            return .clear
        case .button, .destructive:
            return baseBrandColor.opacity(0.1)
        }
    }
    
    // Helper to get the base brand color for the current style
    private var baseBrandColor: Color {
        switch style {
        case .card:
            return .clear // Cards don't have a brand tint in the fallback
        case .button(let color):
            return color
        case .destructive:
            return MindsetColors.accentDestructiveRed
        }
    }
    
    private var fallbackColor: Color {
        switch style {
        case .card:
            return MindsetColors.backgroundCard(for: colorScheme)
        case .button, .destructive:
            // Now 'color' isn't needed here because we use 'baseBrandColor'
            let opacity = (colorScheme == .dark ? 0.1 : 0.15)
            return baseBrandColor.opacity(opacity)
        }
    }
    
    private var fallbackStroke: Color {
        switch style {
        case .card:
            return .clear
        case .button, .destructive:
            let opacity = (colorScheme == .dark ? 0.3 : 0.4)
            return baseBrandColor.opacity(opacity)
        }
    }
}

public extension View {
    /// Standard glass card for static content
    func mindsetCard(radius: CGFloat = MindsetLayout.radiusCard) -> some View {
        self.modifier(MindsetGlassModifier(style: .card, radius: radius))
    }
    
    /// Interactive glass for buttons
    func mindsetButton(color: Color = MindsetColors.accentOrange, radius: CGFloat = MindsetLayout.radiusButton) -> some View {
        self.modifier(MindsetGlassModifier(style: .button(color: color), radius: radius))
    }
    
    /// Specialized glass for destructive actions (like Sign Out)
    func mindsetDestructiveButton(radius: CGFloat = MindsetLayout.radiusButton) -> some View {
        self.modifier(MindsetGlassModifier(style: .destructive, radius: radius))
    }
}
