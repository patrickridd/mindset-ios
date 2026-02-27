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
    
    public init(
        name: String,
        loopMode: LottieLoopMode = .playOnce,
        speed: Double = 1.0
    ) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
    }
    
    public var body: some View {
        // Use the native LottieView initializer
        LottieView(animation: .named(name))
            .configure { lottieAnimationView in
                // Fallback for settings not yet in the top-level declarative API
                lottieAnimationView.animationSpeed = speed
            }
            .playing(loopMode: loopMode) // Declarative playback
            .resizable()
            .scaledToFit()
    }
}
