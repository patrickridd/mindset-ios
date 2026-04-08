//
//  SignOutUseCase.swift
//  Domain
//
//  Created by patrick ridd on 3/22/26.
//

import Foundation

@MainActor
public struct SignOutUseCase {
    private let authService: AuthService
    private let cleaners: [LocalDataCleaner] // Inject a list of things to wipe
    private let clearNonce: () -> Void
    private let logger: AppLogger
    
    public init(authService: AuthService, cleaners: [LocalDataCleaner], clearNonce: @escaping () -> Void, logger: AppLogger) {
        self.authService = authService
        self.cleaners = cleaners
        self.clearNonce = clearNonce
        self.logger = logger
    }

    public func execute() async throws {
        try await authService.signOut()
        
        // Wipe all local caches in parallel
        await withThrowingTaskGroup(of: Void.self) { group in
            for cleaner in cleaners {
                group.addTask { try await cleaner.purgeLocalCache() }
            }
        }
        
        clearNonce()
        logger.log("🚪 User signed out. Local cache cleared. Remote data preserved.")
    }
}
