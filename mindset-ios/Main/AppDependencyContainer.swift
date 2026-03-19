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
        // --- Logger (Composition Root owns the single instance) ---
        let logger: AppLogger = DebugLogger.shared

        // --- Config & Firebase ---
        self.serviceFactory = ServiceFactory(config: .default, logger: logger)

        // --- Services ---
        let subService = serviceFactory.makeSubscriptionService()
        self.authService = serviceFactory.makeAuthService()

        // --- Persistence ---
        self.container = try! ModelContainer(for: SDUserProfile.self, SDMindsetEntry.self)
        self.persistence = SDPersistenceService(modelContext: container.mainContext, logger: logger)

        // --- Repositories ---
        self.mindsetRepository = serviceFactory.makeMindsetRepository(persistence: persistence)
        self.userRepository = serviceFactory.makeUserRepository(persistence: persistence, authStateQuery: authService, logger: logger)

        // --- Use Cases ---
        let getStreak = GetStreakUseCase(repository: mindsetRepository)
        let addMindset = AddMindsetUseCase(repository: mindsetRepository)
        let getYesterday = GetYesterdayGoalUseCase(repository: mindsetRepository)

        let signInOrLinkUseCase = SignInOrLinkUseCase(
            authService: authService,
            userRepository: userRepository,
            logger: logger
        )

        // --- Coordinator & View Factory ---
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
