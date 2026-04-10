//
//  ServiceFactory.swift
//  mindset-ios
//
//  Created by Patrick Ridd
//

import Data
import Development
import Domain
import SwiftData
import SharedUtils

/// Configuration for which services to use (real vs mock)
struct ServiceConfiguration {
    let useRealServices: Bool

    #if DEBUG
    /// In Debug, we check the user's manual toggle.
    /// If useMocks is true, we return a mock config.
    static var `default`: ServiceConfiguration {
        let shouldMock = DebugSettings.shared.useMocks
        return ServiceConfiguration(useRealServices: !shouldMock)
    }
    #else
    /// In Release, we ignore DebugSettings and always use Real Services.
    static let `default` = ServiceConfiguration(useRealServices: true)
    #endif

    static let production = ServiceConfiguration(useRealServices: true)
    static let mock = ServiceConfiguration(useRealServices: false)
}

/// Factory for creating app services with real or mock implementations
struct ServiceFactory {
    let config: ServiceConfiguration
    private let logger: AppLogger

    init(config: ServiceConfiguration = .default, logger: AppLogger) {
        self.config = config
        self.logger = logger
        logger.log("We are in: \(config.useRealServices ? "🌐 PROD" : "🧪 MOCK") Environment")
    }
    
    // MARK: - Service Creation
    
    func makeAuthService() -> AuthService {
        if config.useRealServices {
            return FirebaseAuthService(logger: logger)
        } else {
            return MockAuthService()
        }
    }

    func makeGoogleSignInCredentialProvider() -> GoogleSignInCredentialProvider {
        if config.useRealServices {
            return GoogleSignInCredentialProviderImpl(logger: logger)
        } else {
            return MockGoogleSignInCredentialProvider()
        }
    }

    func makePhoneVerificationProvider() -> PhoneVerificationProvider {
        if config.useRealServices {
            return PhoneVerificationProviderImpl(logger: logger)
        } else {
            return MockPhoneVerificationProvider()
        }
    }

    func makeSubscriptionService() -> any SubscriptionService {
        let base: any SubscriptionService
        if config.useRealServices {
            base = RevenueCatSubscriptionService()
        } else {
            base = MockSubscriptionService()
        }
        #if DEBUG
        return SubscriptionServiceDebugWrapper(wrapping: base)
        #else
        return base
        #endif
    }
    
    func makeAIService() -> AIAnalysisService {
        if config.useRealServices {
            let apiKey = AppConfig.geminiAPIKey
            return GeminiAIService(apiKey: apiKey, logger: logger)
        } else {
            return MockAIService()
        }
    }
    
    // MARK: - Entry Repository Creation
    
    func makeEntryRepository(modelContext: ModelContext, authStateQuery: AuthStateQuery) -> EntryRepository {
        if config.useRealServices {
            let local = makeLocalEntryRepository(modelContext: modelContext)
            let remote = makeRemoteEntryRepository(authStateQuery: authStateQuery)
            return AppEntryRepository(local: local, remote: remote, authStateQuery: authStateQuery, logger: logger)
        } else {
            return MockEntryRepository(days: 11)
        }
    }

    func makeLocalEntryRepository(modelContext: ModelContext) -> EntryRepository {
        if config.useRealServices {
            return SDEntryRepository(modelContext: modelContext, logger: logger)
        } else {
            return MockEntryRepository(days: 11)
        }
    }

    func makeRemoteEntryRepository(authStateQuery: AuthStateQuery) -> EntryRepository {
        if config.useRealServices {
            return FirestoreEntryRepository(authStateQuery: authStateQuery, logger: logger)
        } else {
            return MockEntryRepository(days: 11)
        }
    }

    // MARK: - User Repository Creation

    func makeUserRepository(modelContext: ModelContext, authStateQuery: AuthStateQuery) -> UserRepository {
        let base: any UserRepository
        if config.useRealServices {
            let local = makeLocalUserRepository(modelContext: modelContext)
            let remote =  FirestoreUserRepository(authStateQuery: authStateQuery, logger: logger)
            base = AppUserRepository(local: local, remote: remote, authStateQuery: authStateQuery, logger:  logger)
        } else {
            base = MockUserRepository()
        }
        #if DEBUG
        return UserRepositoryDebugWrapper(wrapping: base)
        #else
        return base
        #endif
    }

    func makeLocalUserRepository(modelContext: ModelContext) -> UserRepository {
        let base: any UserRepository
        if config.useRealServices {
            base = SDUserRepository(modelContext: modelContext, logger: logger)
        } else {
            base = MockUserRepository()
        }
        #if DEBUG
        return UserRepositoryDebugWrapper(wrapping: base)
        #else
        return base
        #endif
    }

    func makeRemoteUserRepository(authStateQuery: AuthStateQuery) -> UserRepository {
        let base: any UserRepository
        if config.useRealServices {
            base = FirestoreUserRepository(authStateQuery: authStateQuery, logger: logger)
        } else {
            base = MockUserRepository()
        }
        #if DEBUG
        return UserRepositoryDebugWrapper(wrapping: base)
        #else
        return base
        #endif
    }

    // MARK: - UserStatsRepository creation

    func makeUserStatsRepository(modelContext: ModelContext, authStateQuery: AuthService) -> UserStatsRepository & UserStatsSyncable {
        let base: any UserStatsRepository & UserStatsSyncable
        if config.useRealServices {
            let local = SDUserStatsRepository(modelContext: modelContext, logger: logger)
            let remote = FirestoreUserStatsRepository(logger: logger)
            base = AppUserStatsRepository(local: local, remote: remote, logger:  logger)
        } else {
            base = MockUserStatsRepository()
        }

        #if DEBUG
        return UserStatsRepositoryDebugWrapper(wrapping: base)
        #else
        return base
        #endif
    }

    func makeLocalUserStatsRepository(modelContext: ModelContext) -> UserStatsRepository & UserStatsSyncable {
        let base: any UserStatsRepository & UserStatsSyncable
        if config.useRealServices {
            base = SDUserStatsRepository(modelContext: modelContext, logger: logger)
        } else {
            base = MockUserStatsRepository()
        }
        #if DEBUG
        return UserStatsRepositoryDebugWrapper(wrapping: base)
        #else
        return base
        #endif
    }

    func makeRemoteUserStatsRepository(authStateQuery: AuthStateQuery) -> UserStatsRepository & UserStatsSyncable {
        let base: any UserStatsRepository & UserStatsSyncable
        if config.useRealServices {
            base = FirestoreUserStatsRepository(logger: logger)
        } else {
            base = MockUserStatsRepository()
        }
        #if DEBUG
        return UserStatsRepositoryDebugWrapper(wrapping: base)
        #else
        return base
        #endif
    }

    func makeLocalDataCleaners(modelContext: ModelContext) -> [LocalDataCleaner] {
        [SDUserRepository(modelContext: modelContext, logger: logger), SDEntryRepository(modelContext: modelContext, logger: logger)]
    }
    
    // MARK: - Sync Service
    
    func makeSyncService(modelContext: ModelContext, authService: AuthService) -> AppSyncService {
        AppSyncService(
            userLocal: makeLocalUserRepository(modelContext: modelContext),
            userRemote: makeRemoteUserRepository(authStateQuery: authService),
            entryLocal: makeLocalEntryRepository(modelContext: modelContext),
            entryRemote: makeRemoteEntryRepository(authStateQuery: authService),
            userStatsLocal: makeLocalUserStatsRepository(modelContext: modelContext),
            userStatsRemote: makeRemoteUserStatsRepository(authStateQuery: authService),
            authService: authService,
            logger: logger
        )
    }
}
