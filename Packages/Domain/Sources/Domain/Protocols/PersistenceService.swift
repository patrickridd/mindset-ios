//
//  PersistenceService.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

public protocol PersistenceService: Sendable {
    func saveUserProfile(_ profile: UserProfile) async throws
    func fetchUserProfile() async throws -> UserProfile?

    func saveEntry(_ entry: Entry) async throws
    func fetchAllMindsetEntries() async throws -> [Entry]

    /// Delete all locally persisted user data (profile + journal history).
    /// Used for account deletion and privacy resets.
    func deleteAllLocalUserData() async throws
}
