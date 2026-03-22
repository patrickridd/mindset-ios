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
    private let userRepository: UserRepository
    private let entryRepository: EntryRepository
    private let clearNonceStorageSessionData: () -> Void
    private let logger: AppLogger
    private let notificationCenter: NotificationCenter

    public init(
        authService: AuthService,
        userRepository: UserRepository,
        entryRepository: EntryRepository,
        clearNonceStorageSessionData: @escaping () -> Void,
        logger: AppLogger,
        notificationCenter: NotificationCenter = .default
    ) {
        self.authService = authService
        self.userRepository = userRepository
        self.entryRepository = entryRepository
        self.clearNonceStorageSessionData = clearNonceStorageSessionData
        self.logger = logger
        self.notificationCenter = notificationCenter
    }

    public func execute() async throws {
        // 1. Sign out from Firebase/Auth provider
        // We do this first so any background listeners are killed immediately
        try await authService.signOut()

        // 2. Clear Local Data Only
        // Note: We call these on the Repositories, which should handle 
        // Ensure we inject Local SwiftData User/Entry Repositories (NOT the Firestore 'delete').
        try await entryRepository.deleteAllEntries()
        try await userRepository.deleteProfile()

        // 3. Clear Apple Sign-In Nonce/Session data
        clearNonceStorageSessionData()

        logger.log("🚪 User signed out. Local cache cleared. Remote data preserved.")

        notificationCenter.post(name: .databaseDidChange, object: nil)
    }
}
