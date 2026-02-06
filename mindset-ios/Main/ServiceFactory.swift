//
//  ServiceFactory.swift
//  mindset-ios
//
//  Created by AI Assistant
//

import Foundation
import Domain
import Data

/// Configuration for which services to use (real vs mock)
struct ServiceConfiguration {
    let useRealServices: Bool
    
    #if DEBUG
    /// In Debug builds, default to mock services
    static let `default` = ServiceConfiguration(useRealServices: false)
    #else
    /// In Release builds, always use real services
    static let `default` = ServiceConfiguration(useRealServices: true)
    #endif
    
    /// Force real services (useful for debug testing with real backends)
    static let production = ServiceConfiguration(useRealServices: true)
    
    /// Force mock services (useful for previews and UI testing)
    static let mock = ServiceConfiguration(useRealServices: false)
}

/// Factory for creating app services with real or mock implementations
struct ServiceFactory {
    let config: ServiceConfiguration
    
    init(config: ServiceConfiguration = .default) {
        self.config = config
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
            return GeminiAIService(apiKey: apiKey)
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
