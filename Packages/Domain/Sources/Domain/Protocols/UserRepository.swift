//
//  UserRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

public protocol UserRepository: Sendable {
    func fetchUserProfile() async throws -> UserProfile?
    func saveUserProfile(_ profile: UserProfile) async throws
}
