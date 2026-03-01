//
//  MindsetCardModifier.swift
//  SharedUI
//
//  Created by patrick ridd on 3/1/26.
//


import SwiftUI

public struct MindsetCardModifier: ViewModifier {
    let radius: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    public init(radius: CGFloat = MindsetLayout.radiusCard) {
        self.radius = radius
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: radius))
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: radius)
                        .fill(MindsetColors.backgroundCard(for: colorScheme))
                )
        }
    }
}

// MARK: - View Extension
public extension View {
    /// Applies the standard Mindset "Liquid Glass" effect or fallback background.
    func mindsetCard(radius: CGFloat = MindsetLayout.radiusCard) -> some View {
        self.modifier(MindsetCardModifier(radius: radius))
    }
}