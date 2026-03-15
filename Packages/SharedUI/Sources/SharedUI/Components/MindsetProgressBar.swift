//
//  MindsetProgressBar.swift
//  SharedUI
//
//  Reusable gradient progress bar (0...1). Used in onboarding and morning ritual.
//

import SwiftUI

/// A horizontal progress bar with coral-to-orange gradient fill. Progress is in 0...1.
public struct MindsetProgressBar: View {
    let progress: Double
    let animationInterval: Double

    let backgroundFillColor: Color
    public init(backgroundFillColor: Color, progress: Double, animationInterval: Double = 0.5) {
        self.backgroundFillColor = backgroundFillColor
        self.progress = progress
        self.animationInterval = animationInterval
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: MindsetLayout.radiusSmall)
                    .fill(backgroundFillColor)
                    .frame(height: MindsetLayout.progressBarHeight)

                RoundedRectangle(cornerRadius: MindsetLayout.radiusSmall)
                    .fill(
                        LinearGradient(
                            colors: [MindsetColors.accentCoral, MindsetColors.accentOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(0, geometry.size.width * progress),
                        height: MindsetLayout.progressBarHeight
                    )
            }
        }
        .frame(height: MindsetLayout.progressBarHeight)
        .animation(.easeInOut(duration: animationInterval), value: progress)
    }
}
