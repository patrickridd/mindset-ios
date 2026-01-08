//
//  PaywallView.swift
//  FeatureSubscription
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI

public struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    
    var onPurchase: () -> Void // The Coordinator will handle this transition

    public init(onPurchase: @escaping () -> Void) {
        self.onPurchase = onPurchase
    }
    
    public var body: some View {
        ZStack {
            // Background: Subtle Gradient
            LinearGradient(colors: [.black, Color(white: 0.1)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Close Button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.title2)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Header
                VStack(spacing: 10) {
                    Text("MINDSET PRO")
                        .font(.caption)
                        .fontWeight(.black)
                        .tracking(3)
                        .foregroundStyle(.orange)
                    
                    Text("Unlock Your Full Potential")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }

                // Feature List
                VStack(alignment: .leading, spacing: 20) {
                    featureRow(icon: "sparkles", title: "Daily Identity Archetypes", sub: "Personalized insights based on your ritual.")
                    featureRow(icon: "clock.arrow.2.circlepath", title: "The Yesterday Bridge", sub: "Connect today's goals with yesterday's wins.")
                    featureRow(icon: "cloud.fill", title: "Cross-Platform Sync", sub: "Access your journey on iOS and Android.")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.05)))
                .padding(.horizontal)

                Spacer()

                // Call to Action
                VStack(spacing: 15) {
                    Button(action: { /* Start Trial Logic */ }) {
                        Text("Start 7-Day Free Trial")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Capsule().fill(Color.orange))
                    }
                    
                    Text("Then $9.99/month. Cancel anytime.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
    }

    private func featureRow(icon: String, title: String, sub: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).fontWeight(.bold).foregroundStyle(.white)
                Text(sub).font(.footnote).foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}
