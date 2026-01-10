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
import Domain
import Data

@main
struct MindsetApp: App {
    let container: ModelContainer
    let persistence: SwiftDataPersistenceService
    let mindsetRepository: SwiftDataMindsetRepository
    let userRepository: SwiftDataUserRepository
    let getStreakUseCase: GetStreakUseCase
    
    @State private var coordinator: MainCoordinator

    init() {
        // 1. Bottom Level: Database
        container = try! ModelContainer(for: SDUserProfile.self, SDMindsetEntry.self)
        
        // 2. Level 2: Raw Persistence Driver
        persistence = SwiftDataPersistenceService(modelContext: container.mainContext)
        
        // 3. Level 3: Domain-Specific Repositories
        mindsetRepository = SwiftDataMindsetRepository(persistence: persistence)
        userRepository = SwiftDataUserRepository(persistence: persistence)
        
        // 4. Level 4: Business Logic (Use Case)
        getStreakUseCase = GetStreakUseCase(repository: mindsetRepository)
        
        // 5. Top Level: Orchestration
        let subService = RevenueCatSubscriptionService()
        _coordinator = State(initialValue: MainCoordinator(
            subscriptionService: subService,
            mindsetRepository: mindsetRepository,
            userRepository: userRepository
        ))
    }

    var body: some Scene {
        WindowGroup {
            // 4. Wire the CoordinatorView with the concrete View factories
            MainCoordinatorView(
                coordinator: coordinator,
                onboardingView: {
                    OnboardingView(
//                        persistenceService: persistenceService,
                        onComplete: { coordinator.onboardingFinished() }
                    )
                },
                paywallView: {
                    PaywallView(onPurchase: { coordinator.subscriptionPurchased() })
                },
                dashboardView: {
                    DashboardView(userRepository: userRepository, mindsetRepository: mindsetRepository, getStreakUseCase: getStreakUseCase) {
                        
                    }
                }
            )
        }
        .modelContainer(container)
    }
}
