//
//  PulsatingCoachView.swift
//  SharedUI
//
//  Created by patrick ridd on 2/13/26.
//

import SharedUtils
import SwiftUI

public struct PulsatingCoachView: View {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing: Bool = false
    @State private var animationTask: Task<Void, Never>? = nil

    let emoji: String
    let enableHaptics: Bool

    private enum Constants {
        static let animationDuration: CGFloat = 0.8
        static let pulseScaleMin: CGFloat = 1.0
        static let pulseScaleMax: CGFloat = 1.2
        static let glowOpacityMin: Double = 0.3
        static let glowOpacityMax: Double = 0.8
        static let emojiFontSize: CGFloat = 48
    }

    private var currentScale: CGFloat {
        isPulsing ? Constants.pulseScaleMax : Constants.pulseScaleMin
    }
    private var currentGlowOpacity: Double {
        isPulsing ? Constants.glowOpacityMax : Constants.glowOpacityMin
    }

    public init(emoji: String, enableHaptics: Bool = true) {
        self.emoji = emoji
        self.enableHaptics = enableHaptics
    }

    public var body: some View {
        ZStack {
            glowEffect
            emojiView
        }
        .onAppear {
            guard !reduceMotion else { return }
            animationTask = Task {
                while !Task.isCancelled {
                    isPulsing = true
                    if enableHaptics {
                        // Haptic fires at the peak of the pulse
                        try? await Task.sleep(
                            for: .milliseconds(Int(Constants.animationDuration * 1000)))
                        HapticManager.tick()
                    }
                    try? await Task.sleep(
                        for: .milliseconds(Int(Constants.animationDuration * 1000)))

                    isPulsing = false
                    try? await Task.sleep(
                        for: .milliseconds(Int(Constants.animationDuration * 1000)))
                }
            }
        }
        .onDisappear {
            animationTask?.cancel()
        }
    }

    @ViewBuilder
    private var glowEffect: some View {
        Circle()
            .fill(.indigo.opacity(0.5))
            .frame(width: MindsetLayout.iconExtraLarge, height: MindsetLayout.iconExtraLarge)
            .scaleEffect(currentScale * 1.2)
            .opacity(currentGlowOpacity)
            .animation(.easeInOut(duration: Constants.animationDuration), value: isPulsing)
    }

    @ViewBuilder
    private var emojiView: some View {
        Text(emoji)
            .font(.system(size: Constants.emojiFontSize))
            .scaleEffect(currentScale)
            .animation(.easeInOut(duration: Constants.animationDuration), value: isPulsing)
    }
}

#Preview {
    PulsatingCoachView(emoji: "🧘‍♂️")
}
