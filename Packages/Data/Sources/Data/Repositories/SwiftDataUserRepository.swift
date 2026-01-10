//
//  SwiftDataUserRepository.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//


import Domain

public final class SwiftDataUserRepository: UserRepository {
    private let persistence: PersistenceService

    public init(persistence: PersistenceService) {
        self.persistence = persistence
    }

    public func fetchUserProfile() async throws -> UserProfile? {
        return try await persistence.fetchUserProfile()
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        try await persistence.saveUserProfile(profile)
    }
}
