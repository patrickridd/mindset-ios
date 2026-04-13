//
//  UserRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

public protocol UserRepository: Sendable {
    func fetchUser() async throws -> User?
    func saveUser(_ profile: User) async throws
    func deleteUser() async throws
    func isOnboardingComplete() async -> Bool
}
