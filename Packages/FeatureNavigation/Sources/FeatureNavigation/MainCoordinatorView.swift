//
//  MainCoordinatorView.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI
import FeatureOnboarding
import FeatureSubscription

public struct MainCoordinatorView: View {
    @Bindable var coordinator: MainCoordinator
    
    public init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    
    public var body: some View {
        Group {
            switch coordinator.currentState {
            case .onboarding:
                OnboardingView()
//                coordinator.onboardingFinished()
            case .paywall:
                PaywallView()
//                coordinator.subscriptionPurchased()
            case .dashboard:
//                DashboardView()
                EmptyView()
            }
        }
        .transition(.opacity.combined(with: .scale)) // Premium feel
    }
}
