//
//  MutableMockUserRepository.swift
//  Domain
//
//  UserRepository whose stored profile can be updated by save — for tests.
//

import Foundation

@MainActor
public final class MutableMockUserRepository: UserRepository {
    public private(set) var profile: User?

    public init(profile: User? = nil) {
        self.profile = profile
    }

    public func fetchUser() async throws -> User? {
        profile
    }

    public func saveUser(_ newProfile: User) async throws {
        profile = newProfile
    }

    public func isOnboardingComplete() async -> Bool {
        profile?.isOnboardingComplete ?? false
    }

    public func deleteUser() async throws {
        profile = nil
    }
}
