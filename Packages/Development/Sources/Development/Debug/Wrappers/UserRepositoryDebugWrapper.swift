//
//  DebugUserRepositoryWrapper.swift
//  Development
//
//  Created by patrick ridd on 3/3/26.
//


import Domain

/// Decorator that intercepts `UserRepository` calls and applies the
/// `DebugSettings.onboardingComplete` flag before delegating to the wrapped service.
/// Injected at the `ServiceFactory` level in `#if DEBUG` builds only.
public final class UserRepositoryDebugWrapper: UserRepository, @unchecked Sendable {
    
    private let wrapped: any UserRepository

    public init(wrapping service: any UserRepository) {
        self.wrapped = service
    }

    public func fetchUser() async throws -> Domain.User? {
        try await wrapped.fetchUser()
    }

    public func saveUser(_ profile: Domain.User) async throws {
        try await wrapped.saveUser(profile)
    }

    public func isOnboardingComplete() async -> Bool {
        let (overrideEnabled, overrideValue) = await MainActor.run {
            (DebugSettings.shared.onboardingOverrideEnabled, DebugSettings.shared.onboardingOverrideValue)
        }
        if overrideEnabled {
            return overrideValue
        } else {
            return await wrapped.isOnboardingComplete()
        }
    }

    public func deleteUser() async throws {
        try await wrapped.deleteUser()
    }
}
