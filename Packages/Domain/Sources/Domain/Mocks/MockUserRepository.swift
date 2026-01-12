//
//  MockUserRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/11/26.
//

public final class MockUserRepository: UserRepository {
    private let mockProfile: UserProfile?

    public init(mockProfile: UserProfile? = nil) {
        self.mockProfile = mockProfile
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
