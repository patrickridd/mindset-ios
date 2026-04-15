//
//  MindsetAnimation.swift
//  SharedUI
//
//  Created by patrick ridd on 2/26/26.
//

import Lottie
import SwiftUI

public struct MindsetAnimationView: View {
    let animation: MindsetAnimation
    let loopMode: LottieLoopMode
    let speed: Double
    let contentMode: ContentMode
    let onCompleted: (() -> Void)?

    @State private var isPlaying = false

    public init(
        animation: MindsetAnimation,
        loopMode: LottieLoopMode = .playOnce,
        speed: Double = 1.0,
        contentMode: ContentMode = .fit,
        onCompleted: (() -> Void)? = nil
    ) {
        self.animation = animation
        self.loopMode = loopMode
        self.speed = speed
        self.contentMode = contentMode
        self.onCompleted = onCompleted
    }

    public var body: some View {
        LottieView {
            try await DotLottieFile.named(animation.rawValue, bundle: .module)
        }
        .configure { lottie in
            lottie.animationSpeed = speed
            lottie.contentMode = uiViewContentMode()
            lottie.configuration.renderingEngine = .mainThread
        }
        .playbackMode(
            isPlaying ? .playing(.fromProgress(0, toProgress: 1, loopMode: loopMode)) : .paused
        )
        .animationDidFinish { completed in
            if completed { onCompleted?() }
        }
        .resizable()
        .aspectRatio(contentMode: contentMode)
        .onAppear { isPlaying = true }
    }

    func uiViewContentMode() -> UIView.ContentMode {
        switch self.contentMode {
        case .fit:
            return .scaleAspectFit
        case .fill:
            return .scaleToFill
        }
    }
}

#Preview {
    MindsetAnimationView(animation: .checkmarkSuccess)
}
