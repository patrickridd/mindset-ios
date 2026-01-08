//
//  MainCoordinatorView.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI
import Domain

public struct MainCoordinatorView<Onboarding: View, Paywall: View, Dashboard: View>: View {
    @Bindable var coordinator: MainCoordinator
    
    // These are "View Builders" injected from the @main app
    let onboardingView: () -> Onboarding
    let paywallView: () -> Paywall
    let dashboardView: () -> Dashboard
    
    public init(
        coordinator: MainCoordinator,
        @ViewBuilder onboardingView: @escaping () -> Onboarding,
        @ViewBuilder paywallView: @escaping () -> Paywall,
        @ViewBuilder dashboardView: @escaping () -> Dashboard
    ) {
        self.coordinator = coordinator
        self.onboardingView = onboardingView
        self.paywallView = paywallView
        self.dashboardView = dashboardView
    }
    
    public var body: some View {
        Group {
            switch coordinator.currentState {
            case .onboarding:
                onboardingView()
            case .paywall:
                paywallView()
            case .dashboard:
                dashboardView()
            }
        }
        .transition(.opacity.combined(with: .scale)) // Premium feel
    }
}
