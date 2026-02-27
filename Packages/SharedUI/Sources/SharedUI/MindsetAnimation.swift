//
//  MindsetAnimation.swift
//  SharedUI
//
//  Created by patrick ridd on 2/26/26.
//

import Lottie
import SwiftUI

public struct MindsetAnimation: View {
    let name: String
    let loopMode: LottieLoopMode
    let speed: Double
    let onCompleted: (() -> Void)?
    
    @State private var isPlaying = false
    
    public init(
        name: String,
        loopMode: LottieLoopMode = .playOnce,
        speed: Double = 1.0,
        onCompleted: (() -> Void)? = nil
    ) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        LottieView(animation: .named(name, bundle: .module))
            .configure { lottie in
                lottie.animationSpeed = speed
                lottie.contentMode = .scaleAspectFit
            }
            .playbackMode(isPlaying ? .playing(.fromProgress(0, toProgress: 1, loopMode: loopMode)) : .paused)
            .animationDidFinish { completed in
                if completed {
                    onCompleted?()
                }
            }
            .resizable()
            .scaledToFit()
            .onAppear {
                isPlaying = true
            }
    }
}

#Preview {
    MindsetAnimation(name: "Checkmark-Success-Animation")
}
