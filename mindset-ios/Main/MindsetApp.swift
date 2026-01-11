//
//  MindsetApp.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/2/26.
//

import Foundation
import SwiftUI
import SwiftData
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
    let persistence: SwiftDataPersistenceService
    let mindsetRepository: SwiftDataMindsetRepository
    let userRepository: SwiftDataUserRepository
    
    /// Use Cases
    let getStreakUseCase: GetStreakUseCase
    let addMindsetUseCase: AddMindsetUseCase
    let getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase
    
    /// Services
    let subscriptionService: SubscriptionService

    @State private var coordinator: MainCoordinator
    private let viewFactory: AppViewFactory

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
        addMindsetUseCase = AddMindsetUseCase(repository: mindsetRepository)
        getYesterdayBridgeUseCase = GetYesterdayBridgeUseCase(repository: mindsetRepository)

        subscriptionService = RevenueCatSubscriptionService()
        
        let coord = MainCoordinator(
            subscriptionService: subscriptionService,
            mindsetRepository: mindsetRepository,
            userRepository: userRepository
        )
                
        _coordinator = State(initialValue: coord)
                
        // Initialize the factory with all the dependencies it needs to "assemble" views
        self.viewFactory = AppViewFactory(
            coordinator: coord,
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreakUseCase,
            addMindsetUseCase: addMindsetUseCase,
            getYesterdayBridgeUseCase: getYesterdayBridgeUseCase,
            subscriptionService: subscriptionService
        )
    }

    var body: some Scene {
        WindowGroup {
            MainCoordinatorView(coordinator: coordinator, factory: viewFactory)
        }
        .modelContainer(container)
    }
}
