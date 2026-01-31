//
//  RitualSuccessView.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/13/26.
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

public struct RitualSuccessView: View {
    let archetype: String
    let xpEarned: Int
    let onDismiss: () -> Void
    
    @State private var progress: Double = 0.0

    public init(archetype: String, xpEarned: Int, onDismiss: @escaping () -> Void) {
        self.archetype = archetype
        self.xpEarned = xpEarned
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: MindsetLayout.spacing30) {
            Spacer()
            
            // 1. Hero Icon
            ZStack {
                Circle()
                    .fill(MindsetColors.accentOrangeSoft)
                    .frame(width: MindsetLayout.heroCircleSize, height: MindsetLayout.heroCircleSize)
                
                Image(systemName: "figure.mindful")
                    .resizable()
                    .scaledToFit()
                    .frame(width: MindsetLayout.iconLarge)
                    .foregroundStyle(MindsetColors.accentOrange)
            }
            
            // 2. Archetype Reveal
            VStack(spacing: MindsetLayout.spacing8) {
                Text("TODAY'S IDENTITY")
                    .font(MindsetFonts.labelUppercase)
                    .tracking(2)
                    .foregroundStyle(.secondary)
                
                Text(archetype)
                    .font(MindsetFonts.displayLarge)
            }
            
            // 3. XP Bar
            VStack(spacing: MindsetLayout.spacing12) {
                HStack {
                    Text("Daily Progress")
                    Spacer()
                    Text("+\(xpEarned) XP").bold().foregroundStyle(MindsetColors.achievementGold)
                }
                .font(MindsetFonts.footnote)
                .padding(.horizontal)
                
                ProgressView(value: progress, total: 100)
                    .tint(MindsetColors.achievementGold)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: MindsetLayout.radiusCardLarge).fill(MindsetColors.backgroundSecondary))
            .padding(.horizontal)

            Spacer()
            
            // 4. Action
            Button(action: onDismiss) {
                Text("Continue to Dashboard")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .tint(MindsetColors.accentOrange)
            .padding()
        }
        .onAppear {
            // 1. Success Thud
            HapticManager.notification(.success)
            
            // 2. XP Bar "Ticking"
            withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                progress = 0.75
            }
            
            // Simulate ticking haptics during animation
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if progress < 0.75 {
                    HapticManager.impact(.light)
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}
