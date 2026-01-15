//
//  RitualSuccessView.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/13/26.
//

import Core
import Domain
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
        VStack(spacing: 30) {
            Spacer()
            
            // 1. Hero Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "figure.mindful")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .foregroundStyle(.orange)
            }
            
            // 2. Archetype Reveal
            VStack(spacing: 8) {
                Text("TODAY'S IDENTITY")
                    .font(.caption2).bold().tracking(2)
                    .foregroundStyle(.secondary)
                
                Text(archetype)
                    .font(.system(.largeTitle, design: .serif))
                    .bold()
            }
            
            // 3. XP Bar
            VStack(spacing: 12) {
                HStack {
                    Text("Daily Progress")
                    Spacer()
                    Text("+\(xpEarned) XP").bold().foregroundStyle(.orange)
                }
                .font(.footnote)
                .padding(.horizontal)
                
                ProgressView(value: progress, total: 100)
                    .tint(.orange)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
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
            .tint(.orange)
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
