//
//  MockUserRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public final class MockUserRepository: UserRepository {
    private let mockProfile: UserProfile

    public init(
        id: String = "mock-user-id",
        userName: String = "Patrick",
        primaryGoal: String = "Feel more confident",
        isOnboardingComplete: Bool = true,
        overwhelmedFrequency: UserProfile.OverwhelmedFrequency = .often
    ) {
        self.mockProfile = UserProfile(
            id: id,
            userName: userName,
            primaryGoal: primaryGoal,
            isOnboardingComplete: isOnboardingComplete,
            overwhelmedFrequency: overwhelmedFrequency
        )
    }

    public func isOnboardingComplete() -> Bool {
        mockProfile.isOnboardingComplete
    }

    public func fetchUserProfile() async throws -> UserProfile? {
        // Simulate a small network/DB delay
        try? await Task.sleep(for: .seconds(0.5))
        return mockProfile
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        // No-op for mocks
    }
}
