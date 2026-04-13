//
//  MockUserRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

import Foundation

public final class MockUserRepository: UserRepository {
    private let mockProfile: User

    public init(
        id: String = "mock-user-id",
        userName: String = "Patrick",
        isOnboardingComplete: Bool = true,
        overwhelmedFrequency: OnboardingData.OverwhelmedFrequency = .often,
        isAccountSecured: Bool = true,
        createdAt: Date = .init()
    ) {
        self.mockProfile = User(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: createdAt,
            userName: userName,
            isAccountSecured: isAccountSecured,
            isOnboardingComplete: isOnboardingComplete,
            onboardingData: OnboardingData(),
            stats: UserStats()
        )
    }

    public func isOnboardingComplete() -> Bool {
        mockProfile.isOnboardingComplete
    }

    public func fetchUser() async throws -> User? {
        // Simulate a small network/DB delay
        try? await Task.sleep(for: .seconds(0.5))
        return mockProfile
    }

    public func saveUser(_ profile: User) async throws {
        // No-op for mocks
    }

    public func deleteUser() async throws {
        // No-op for mocks
    }
}
