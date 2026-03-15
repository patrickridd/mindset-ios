//
//  MutableMockUserRepository.swift
//  Domain
//
//  UserRepository whose stored profile can be updated by save — for tests.
//

import Foundation

@MainActor
public final class MutableMockUserRepository: UserRepository {
    public private(set) var profile: UserProfile?

    public init(profile: UserProfile? = nil) {
        self.profile = profile
    }

    public func fetchUserProfile() async throws -> UserProfile? {
        profile
    }

    public func saveUserProfile(_ newProfile: UserProfile) async throws {
        profile = newProfile
    }

    public func isOnboardingComplete() async -> Bool {
        profile?.isOnboardingComplete ?? false
    }
}
