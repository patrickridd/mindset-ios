//
//  ServiceFactory.swift
//  mindset-ios
//
//  Created by AI Assistant
//

import Data
import Development
import Domain
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
            return FirebaseAuthService()
        } else {
            return MockAuthService()
        }
    }
    
    func makeSubscriptionService() -> SubscriptionService {
        if config.useRealServices {
            return RevenueCatSubscriptionService()
        } else {
            return MockSubscriptionService()
        }
    }
    
    func makeAIService() -> AIAnalysisService {
        if config.useRealServices {
            let apiKey = AppConfig.geminiAPIKey
            return GeminiAIService(apiKey: apiKey, logger: logger)
        } else {
            return MockAIService()
        }
    }
    
    // MARK: - Repository Creation
    
    func makeMindsetRepository(persistence: SDPersistenceService) -> MindsetRepository {
        if config.useRealServices {
            return SDMindsetRepository(persistence: persistence)
        } else {
            return MockMindsetRepository(days: 11)
        }
    }
    
    func makeUserRepository(persistence: SDPersistenceService) -> UserRepository {
        if config.useRealServices {
            return SDUserRepository(persistence: persistence)
        } else {
            return MockUserRepository()
        }
    }
}
