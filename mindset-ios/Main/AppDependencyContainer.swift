//
//  AppDependencyContainer.swift
//  mindset-ios
//
//  Created by patrick ridd on 3/1/26.
//

import Data
import Domain
import FeatureDashboard
import FeatureMindset
import FeatureNavigation
import FeatureOnboarding
import FeatureSubscription
import FirebaseCore
import Foundation
import SharedUI
import SharedUtils
import SwiftData

@Observable
final class AppDependencyContainer {
    let serviceFactory: ServiceFactory
    let authService: AuthService
    let userRepository: UserRepository
    let mindsetRepository: MindsetRepository
    let coordinator: MainCoordinator
    let viewFactory: AppViewFactory
    let container: ModelContainer
    let persistence: PersistenceService

    init() {
        // --- 1. Logger (Composition Root owns the single instance) ---
        let logger: AppLogger = DebugLogger.shared

        // --- 2. Config & Firebase ---
        self.serviceFactory = ServiceFactory(config: .default, logger: logger)
        if serviceFactory.config.useRealServices {
            // FirebaseApp.configure() handles multiple calls gracefully in 2026, 
            // but you can wrap it in a 'if FirebaseApp.app() == nil' if needed.
            if FirebaseApp.app() == nil { FirebaseApp.configure() }
        }

        // --- 3. Persistence ---
        self.container = try! ModelContainer(for: SDUserProfile.self, SDMindsetEntry.self)
        self.persistence = SDPersistenceService(modelContext: container.mainContext)

        // --- 4. Repositories ---
        self.mindsetRepository = serviceFactory.makeMindsetRepository(persistence: persistence)
        self.userRepository = serviceFactory.makeUserRepository(persistence: persistence)

        // --- 5. Use Cases ---
        let getStreak = GetStreakUseCase(repository: mindsetRepository)
        let addMindset = AddMindsetUseCase(repository: mindsetRepository)
        let getYesterday = GetYesterdayGoalUseCase(repository: mindsetRepository)

        // --- 6. Services ---
        let subService = serviceFactory.makeSubscriptionService()
        self.authService = serviceFactory.makeAuthService()

        let signInOrLinkUseCase = SignInOrLinkUseCase(authService: authService)

        // --- 7. Coordinator & View Factory ---
        self.coordinator = MainCoordinator(
            authStateQuery: authService,
            subscriptionService: subService,
            mindsetRepository: mindsetRepository,
            userRepository: userRepository
        )

        let appleSignInNonceStorage = AppleSignInNonceStorage()

        self.viewFactory = AppViewFactory(
            coordinator: coordinator,
            authService: authService,
            signInOrLinkUseCase: signInOrLinkUseCase,
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreak,
            addMindsetUseCase: addMindset,
            getYesterdayGoalUseCase: getYesterday,
            subscriptionService: subService,
            serviceFactory: serviceFactory,
            persistence: persistence,
            logger: logger,
            appleSignInNonceStorage: appleSignInNonceStorage
        )
    }
}
