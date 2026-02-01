//
//  PaywallView.swift
//  FeatureSubscription
//
//  Created by patrick ridd on 1/7/26.
//

import Domain
import SharedUI
import SwiftUI

public struct PaywallView: View {
    @State private var viewModel: PaywallViewModel
    
    public init(viewModel: PaywallViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    MindsetColors.backgroundDark,
                    MindsetColors.backgroundDarkSoft,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().tint(MindsetColors.accentOrange)
            } else {
                content
            }
        }
    }

    private var content: some View {
        VStack(spacing: MindsetLayout.spacing25) {
            // ... Header and Feature List remain the same ...
            // Close Button
            HStack {
                DismissButton(action: viewModel.dismissButtonTapped)
                Spacer()
            }
            .padding(.horizontal)
            
            // Header
            VStack(spacing: MindsetLayout.spacing10) {
                Text("MINDSET PRO")
                    .font(MindsetFonts.labelUppercase)
                    .tracking(3)
                    .foregroundStyle(MindsetColors.accentOrange)
                
                Text("Unlock Your Full Potential")
                    .font(MindsetFonts.displayLarge)
                    .foregroundStyle(MindsetColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            
            // Feature List
            VStack(alignment: .leading, spacing: MindsetLayout.spacing20) {
                featureRow(icon: "sparkles", title: "Daily Identity Archetypes", sub: "Personalized insights based on your ritual.")
                featureRow(icon: "clock.arrow.2.circlepath", title: "The Yesterday Bridge", sub: "Connect today's goals with yesterday's wins.")
                featureRow(icon: "cloud.fill", title: "Cross-Platform Sync", sub: "Access your journey on iOS and Android.")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: MindsetLayout.radiusCardLarge).fill(MindsetColors.fillSubtle))
            .padding(.horizontal)
            
            Spacer()
            
            // Call to Action
            VStack(spacing: MindsetLayout.spacing15) {
                Button(action: { Task { try await viewModel.purchase() } }) {
                    Text("Start 7-Day Free Trial")
                        .font(MindsetFonts.button)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: MindsetLayout.buttonHeight)
                        .background(Capsule().fill(MindsetColors.accentOrange))
                }

                Text("Then $9.99/month. Cancel anytime.")
                    .font(MindsetFonts.caption)
                    .foregroundStyle(MindsetColors.textSecondary)
            }
            .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
            .padding(.bottom, MindsetLayout.paddingLarge)
        }
    }
    
    private func featureRow(icon: String, title: String, sub: String) -> some View {
        HStack(alignment: .top, spacing: MindsetLayout.spacing15) {
            Image(systemName: icon)
                .foregroundStyle(MindsetColors.accentOrange)
                .font(MindsetFonts.featureTitle)
            VStack(alignment: .leading, spacing: MindsetLayout.spacing4) {
                Text(title).font(MindsetFonts.featureTitle).fontWeight(.bold).foregroundStyle(MindsetColors.textPrimary)
                Text(sub).font(MindsetFonts.footnote).foregroundStyle(MindsetColors.textSecondary)
            }
        }
    }
}

#Preview {
    let viewModel = PaywallViewModel(subscriptionService: MockSubscriptionService()
    ) {
        
    }
    return PaywallView(viewModel: viewModel)
}
