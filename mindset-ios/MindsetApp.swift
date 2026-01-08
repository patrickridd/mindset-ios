//
//  MindsetApp.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/2/26.
//

import SwiftUI
import FeatureNavigation
import FeatureDashboard
import FeatureOnboarding
import FeatureSubscription
import Data

@main
struct MindsetApp: App {
    // 1. Initialize concrete implementations of your Services
    // In a real app, you'd pull these from a Dependency Container
    private let subscriptionService = RevenueCatSubscriptionService()
    
    // 2. Initialize the Director (Coordinator)
    @State private var coordinator: MainCoordinator
    
    init() {
        let coord = MainCoordinator(subscriptionService: subscriptionService)
        _coordinator = State(initialValue: coord)
    }
    
    var body: some Scene {
        WindowGroup {
            // 3. The Coordinator View handles the "Physics" of switching screens
            MainCoordinatorView(
                coordinator: coordinator,
                onboardingView: { OnboardingView(onComplete: { coordinator.onboardingFinished() }) },
                paywallView: { PaywallView(onPurchase: { coordinator.subscriptionPurchased() }) },
                dashboardView: { DashboardView(onStartRitual: { /* navigate to ritual */ }) }
            )
        }
    }
}
