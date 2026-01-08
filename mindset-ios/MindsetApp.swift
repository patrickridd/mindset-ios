//
//  MindsetApp.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/2/26.
//

import SwiftUI
import SwiftData
import FeatureNavigation
import FeatureDashboard
import FeatureOnboarding
import FeatureSubscription
import Data

@main
struct MindsetApp: App {

    let container: ModelContainer
    
    @State private var coordinator: MainCoordinator
    
    init() {
        // Initialize SwiftData
        do {
            container = try ModelContainer(for: MindsetEntryDB.self)
        } catch {
            fatalError("Could not initialize SwiftData container")
        }
        
        // 2. Inject the SwiftData context into a Repository
        let persistenceService = SwiftDataMindsetRepository(modelContext: container.mainContext)
        let subscriptionService = RevenueCatSubscriptionService()
        
        // 3. Initialize the Coordinator
        _coordinator = State(initialValue: MainCoordinator(
            subscriptionService: subscriptionService,
            persistenceService: persistenceService // New dependency
        ))
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
        .modelContainer(container)
    }
}
