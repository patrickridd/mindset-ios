//
//  MindsetAnimation.swift
//  SharedUI
//
//  Created by patrick ridd on 2/26/26.
//

import Lottie
import SharedUtils
import SwiftUI

public struct MindsetAnimation: View {
    let name: String
    let loopMode: LottieLoopMode
    let speed: Double
    let onCompleted: (() -> Void)?
    
    // 1. Add a trigger to kickstart playback on appear
    @State private var isPlaying = false
    
    public init(name: String, loopMode: LottieLoopMode = .playOnce, speed: Double = 1.0, onCompleted: (() -> Void)? = nil) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        LottieView(animation: .named(name, bundle: .module))
            .configure { lottieAnimationView in
                lottieAnimationView.animationSpeed = speed
                lottieAnimationView.contentMode = .scaleAspectFit
                // Ensure we use main thread for maximum compatibility with dotLottie
                lottieAnimationView.configuration.renderingEngine = .mainThread
            }
            // 2. Use the declarative playbackMode tied to our state
            .playbackMode(isPlaying ? .playing(.fromProgress(0, toProgress: 1, loopMode: loopMode)) : .paused)
            .animationDidFinish { completed in
                if completed {
                    onCompleted?()
                }
            }
            .resizable()
            .scaledToFit()
            .onAppear {
                // 3. Kickstart the animation after the view is in the hierarchy
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPlaying = true
                }
            }
    }
}

#Preview {
    MindsetAnimation(name: "Checkmark-Success-Animation")
}
