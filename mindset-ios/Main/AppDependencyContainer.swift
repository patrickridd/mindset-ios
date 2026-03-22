//
//  AppDependencyContainer.swift
//  mindset-ios
//
//  Created by patrick ridd on 3/1/26.
//

import Combine
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

@MainActor
final class AppDependencyContainer: ObservableObject {
    
    // 1. Manually add the publisher the compiler is asking for
    public let objectWillChange = ObservableObjectPublisher()
    // Properties remain let/constant as they are dependencies
    let serviceFactory: ServiceFactory
    let authService: AuthService
    let userRepository: UserRepository
    let mindsetRepository: EntryRepository
    let coordinator: MainCoordinator
    let viewFactory: AppViewFactory
    let container: ModelContainer
    let persistence: PersistenceService
    let syncService: UserSyncService

    init() {
        // --- Logger ---
        let logger: AppLogger = DebugLogger.shared

        // --- Config & Firebase ---
        self.serviceFactory = ServiceFactory(config: .default, logger: logger)

        // --- Services ---
        let subService = serviceFactory.makeSubscriptionService()
        self.authService = serviceFactory.makeAuthService()

        // --- Persistence ---
        // Using try! is okay here since this is the Composition Root
        // and we want to know immediately if the DB schema is broken.
        self.container = try! ModelContainer(for: SDUserProfile.self, SDEntry.self)
        self.persistence = SDPersistenceService(modelContext: container.mainContext, logger: logger)

        // --- Repositories ---
        self.mindsetRepository = serviceFactory.makeEntryRepository(modelContext: container.mainContext, authStateQuery: authService)
        self.userRepository = serviceFactory.makeUserRepository(modelContext: container.mainContext, authStateQuery: authService)

        self.syncService = UserSyncService(
            userRepository: userRepository,
            authService: authService,
            logger: logger
        )
    
        let appleSignInNonceStorage = AppleSignInNonceStorage()

        // --- Use Cases ---
        let getStreak = GetStreakUseCase(repository: mindsetRepository)
        let addMindset = AddEntryUseCase(repository: mindsetRepository)
        let getYesterday = GetYesterdayGoalUseCase(repository: mindsetRepository)

        let deleteAccountUseCase = DeleteAccountUseCase(
            authService: authService, userRepository: userRepository,
            entryRepository: mindsetRepository,
            clearNonce: appleSignInNonceStorage.clearSessionData,
            logger: logger
        )

        let signOutUseCase = SignOutUseCase(
            authService: authService,
            cleaners: [SDUserRepository(modelContext: container.mainContext, logger: logger),
                       SDEntryRepository(modelContext: container.mainContext, logger: logger)],
            clearNonce: appleSignInNonceStorage.clearSessionData,
            logger: logger
        )

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
            userRepository: userRepository,
            syncService: syncService
        )

        self.viewFactory = AppViewFactory(
            coordinator: coordinator,
            authService: authService,
            signInOrLinkUseCase: signInOrLinkUseCase,
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreak,
            addEntryUseCase: addMindset,
            deleteAccountUseCase: deleteAccountUseCase,
            signOutUseCase: signOutUseCase,
            getYesterdayGoalUseCase: getYesterday,
            subscriptionService: subService,
            serviceFactory: serviceFactory,
            persistence: persistence,
            logger: logger,
            appleSignInNonceStorage: appleSignInNonceStorage
        )
        
        logger.log("🏗️ AppDependencyContainer fully initialized.")
    }
}
