//
//  DeleteAccountUseCase.swift
//  Domain
//
//  Created by patrick ridd on 3/22/26.
//

import Foundation

@MainActor
public struct DeleteAccountUseCase {
    private let authService: AuthService
    private let userRepository: UserRepository
    private let entryRepository: EntryRepository
    private let logger: AppLogger
    private let notificationCenter: NotificationCenter

    public init(
        authService: AuthService,
        userRepository: UserRepository,
        entryRepository: EntryRepository,
        logger: AppLogger,
        notificationCenter: NotificationCenter = .default
    ) {
        self.authService = authService
        self.userRepository = userRepository
        self.entryRepository = entryRepository
        self.logger = logger
        self.notificationCenter = notificationCenter
    }

    public func execute() async throws {
        //  Delete Data (Order matters: Entries -> UserProfile -> Auth User)
        try await entryRepository.deleteAllEntries()
        try await userRepository.deleteProfile()
        try await authService.deleteCurrentUser()

        logger.log("👤 Account fully purged from Earth and Cloud.")
        notificationCenter.post(name: .databaseDidChange, object: nil)
    }
}
