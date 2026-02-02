//
//  MindsetApp.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/2/26.
//

import Foundation
import SwiftUI
import SharedUI
import SharedUtils
import SwiftData
import FirebaseCore
import FeatureNavigation
import FeatureDashboard
import FeatureOnboarding
import FeatureSubscription
import FeatureMindset
import Domain
import Data

@main
struct MindsetApp: App {
    /// Repository/Persistence
    let container: ModelContainer
    let persistence: SDPersistenceService
    let mindsetRepository: SDMindsetRepository
    let userRepository: SDUserRepository
    
    /// Use Cases
    let getStreakUseCase: GetStreakUseCase
    let addMindsetUseCase: AddMindsetUseCase
    let getYesterdayGoalUseCase: GetYesterdayGoalUseCase
    
    /// Services
    let subscriptionService: SubscriptionService
    let authService: AuthService

    @State private var coordinator: MainCoordinator
    private let viewFactory: AppViewFactory

    init() {
        // 0. Initialize Firebase FIRST (before any Firebase services)
        FirebaseApp.configure()
        
        // 1. Bottom Level: Database
        container = try! ModelContainer(for: SDUserProfile.self, SDMindsetEntry.self)
        
        // 2. Level 2: Raw Persistence Driver
        persistence = SDPersistenceService(modelContext: container.mainContext)
        
        // 3. Level 3: Domain-Specific Repositories
        mindsetRepository = SDMindsetRepository(persistence: persistence)
        userRepository = SDUserRepository(persistence: persistence)
        
        // 4. Level 4: Business Logic (Use Case)
        getStreakUseCase = GetStreakUseCase(repository: mindsetRepository)
        addMindsetUseCase = AddMindsetUseCase(repository: mindsetRepository)
        getYesterdayGoalUseCase = GetYesterdayGoalUseCase(repository: mindsetRepository)

        // 5. Services (RevenueCat, Firebase Auth)
        subscriptionService = RevenueCatSubscriptionService()
        authService = FirebaseAuthService()
        
        let coord = MainCoordinator(
            authService: authService,
            subscriptionService: subscriptionService,
            mindsetRepository: mindsetRepository,
            userRepository: userRepository
        )
                
        _coordinator = State(initialValue: coord)
                
        // Initialize the factory with all the dependencies it needs to "assemble" views
        self.viewFactory = AppViewFactory(
            coordinator: coord,
            authService: authService,
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreakUseCase,
            addMindsetUseCase: addMindsetUseCase,
            getYesterdayGoalUseCase: getYesterdayGoalUseCase,
            subscriptionService: subscriptionService
        )
    }

    var body: some Scene {
        WindowGroup {
            MainCoordinatorView(coordinator: coordinator, factory: viewFactory)
                .withDebugOverlay()
                .onOpenURL { url in
                    // Delegate OAuth callback handling to AuthService (clean architecture!)
                    // AuthService abstracts the provider-specific logic (Firebase, etc.)
                    let handled = authService.handleAuthCallback(url: url)
                    if handled {
                        DebugLogger.shared.add("✅ AuthService handled OAuth callback: \(url.scheme ?? "unknown")://...")
                    } else {
                        DebugLogger.shared.add("⚠️ Unhandled URL: \(url)")
                    }
                }
        }
        .modelContainer(container)
    }
}
