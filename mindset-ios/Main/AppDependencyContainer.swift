//
//  AppDependencyContainer.swift
//  mindset-ios
//
//  Created by patrick ridd on 3/1/26.
//

import Foundation
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

@Observable
final class AppDependencyContainer {
    let serviceFactory: ServiceFactory
    let authService: AuthService
    let userRepository: UserRepository
    let mindsetRepository: MindsetRepository
    let coordinator: MainCoordinator
    let viewFactory: AppViewFactory
    let container: ModelContainer
    
    init() {
        // --- 1. Config & Firebase ---
        self.serviceFactory = ServiceFactory(config: .default)
        if serviceFactory.config.useRealServices {
            // FirebaseApp.configure() handles multiple calls gracefully in 2026, 
            // but you can wrap it in a 'if FirebaseApp.app() == nil' if needed.
            if FirebaseApp.app() == nil { FirebaseApp.configure() }
        }
        
        // --- 2. Persistence ---
        self.container = try! ModelContainer(for: SDUserProfile.self, SDMindsetEntry.self)
        let persistence = SDPersistenceService(modelContext: container.mainContext)
        
        // --- 3. Repositories ---
        self.mindsetRepository = serviceFactory.makeMindsetRepository(persistence: persistence)
        self.userRepository = serviceFactory.makeUserRepository(persistence: persistence)
        
        // --- 4. Use Cases ---
        let getStreak = GetStreakUseCase(repository: mindsetRepository)
        let addMindset = AddMindsetUseCase(repository: mindsetRepository)
        let getYesterday = GetYesterdayGoalUseCase(repository: mindsetRepository)
        
        // --- 5. Services ---
        let subService = serviceFactory.makeSubscriptionService()
        self.authService = serviceFactory.makeAuthService()
        
        // --- 6. Coordinator & View Factory ---
        self.coordinator = MainCoordinator(
            authService: authService,
            subscriptionService: subService,
            mindsetRepository: mindsetRepository,
            userRepository: userRepository
        )
        
        self.viewFactory = AppViewFactory(
            coordinator: coordinator,
            authService: authService,
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreak,
            addMindsetUseCase: addMindset,
            getYesterdayGoalUseCase: getYesterday,
            subscriptionService: subService,
            serviceFactory: serviceFactory
        )
    }
}
