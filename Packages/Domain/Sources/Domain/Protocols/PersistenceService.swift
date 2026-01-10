//
//  PersistenceService.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

public protocol PersistenceService: Sendable {
    func saveUserProfile(_ profile: UserProfile) async throws
    func fetchUserProfile() async throws -> UserProfile?
    func saveMindsetEntry(_ entry: MindsetEntry) async throws
}
