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
    let mindsetRepository: MindsetRepository
    let userRepository: UserRepository
    
    /// Use Cases
    let getStreakUseCase: GetStreakUseCase
    let addMindsetUseCase: AddMindsetUseCase
    let getYesterdayGoalUseCase: GetYesterdayGoalUseCase
    
    /// Services
    let subscriptionService: SubscriptionService
    let authService: AuthService

    @State private var coordinator: MainCoordinator
    private let viewFactory: AppViewFactory
    
    /// Service configuration (Debug = mock, Release = real)
    private let serviceFactory: ServiceFactory

    init() {
        // 0. Service Configuration
        // In Debug builds, uses mock services by default
        // In Release builds, always uses real services
        // To force real services in Debug: ServiceFactory(config: .production)
        serviceFactory = ServiceFactory(config: .default)
        
        // 1. Initialize Firebase FIRST (before any Firebase services)
        // Only needed if using real services
        if serviceFactory.config.useRealServices {
            FirebaseApp.configure()
        }
        
        // 2. Bottom Level: Database
        container = try! ModelContainer(for: SDUserProfile.self, SDMindsetEntry.self)
        
        // 3. Level 2: Raw Persistence Driver
        persistence = SDPersistenceService(modelContext: container.mainContext)
        
        // 4. Level 3: Domain-Specific Repositories (real or mock)
        mindsetRepository = serviceFactory.makeMindsetRepository(persistence: persistence)
        userRepository = serviceFactory.makeUserRepository(persistence: persistence)
        
        // 5. Level 4: Business Logic (Use Cases)
        getStreakUseCase = GetStreakUseCase(repository: mindsetRepository)
        addMindsetUseCase = AddMindsetUseCase(repository: mindsetRepository)
        getYesterdayGoalUseCase = GetYesterdayGoalUseCase(repository: mindsetRepository)

        // 6. Services (real or mock based on config)
        subscriptionService = serviceFactory.makeSubscriptionService()
        authService = serviceFactory.makeAuthService()
        
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
            subscriptionService: subscriptionService,
            serviceFactory: serviceFactory
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
