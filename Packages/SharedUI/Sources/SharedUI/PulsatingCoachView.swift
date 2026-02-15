//
//  PulsatingCoachView.swift
//  SharedUI
//
//  Created by patrick ridd on 2/13/26.
//

import SwiftUI
import SharedUtils

struct PulsatingCoachView: View {
    let emoji: String
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Subtle glow/halo behind the emoji
            Circle()
                .fill(.indigo.opacity(0.5))
                .frame(width: MindsetLayout.iconExtraLarge, height: MindsetLayout.iconExtraLarge)
                .scaleEffect(pulseScale * 1.2)
                .opacity(glowOpacity)

            // The Coach Icon
            Text(emoji)
                .font(MindsetFonts.bodyMedium)
                .scaleEffect(pulseScale)
        }
        .task {
            // Synchronized Animation and Haptics
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.8)) {
                    pulseScale = 1.2
                    glowOpacity = 0.8
                }
                // Trigger soft haptic at peak of pulse
                HapticManager.tick() 
                
                try? await Task.sleep(for: .milliseconds(800))
                
                withAnimation(.easeInOut(duration: 0.8)) {
                    pulseScale = 1.0
                    glowOpacity = 0.3
                }
                
                try? await Task.sleep(for: .milliseconds(800))
            }
        }
    }
}
