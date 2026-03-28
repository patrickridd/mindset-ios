//
//  MindsetAmbientAnimationView.swift
//  SharedUI
//

import Lottie
import SwiftUI

/// Full-bleed looping Lottie for screen backgrounds. Does not intercept touches; hidden from VoiceOver.
public struct MindsetAmbientAnimationView: View {
    let animation: MindsetAnimation
    let speed: Double
    let opacity: Double

    @State private var isPlaying = false

    public init(
        animation: MindsetAnimation = .startBackground,
        speed: Double = 0.6,
        opacity: Double = 1.0
    ) {
        self.animation = animation
        self.speed = speed
        self.opacity = opacity
    }

    public var body: some View {
        // Color.clear + overlay keeps Lottie's canvas intrinsic size from inflating parent ZStacks.
        Color.clear
            .overlay {
                LottieView {
                    try await DotLottieFile.named(animation.rawValue, bundle: .module)
                }
                .configure { lottie in
                    lottie.animationSpeed = speed
                    lottie.contentMode = .scaleAspectFill
                    lottie.configuration.renderingEngine = .mainThread
                }
                .playbackMode(
                    isPlaying ? .playing(.fromProgress(0, toProgress: 1, loopMode: .loop)) : .paused
                )
                .resizable()
                .scaledToFill()
                .opacity(opacity)
                .clipped()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onAppear { isPlaying = true }
    }
}

#Preview("Ambient") {
    MindsetAmbientAnimationView()
}
