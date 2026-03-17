//
//  PersistenceService.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

public protocol PersistenceService: Sendable {
    func saveUserProfile(_ profile: UserProfile) async throws
    func fetchUserProfile() async throws -> UserProfile?

    func saveEntry(_ entry: MindsetEntry) async throws
    func fetchAllMindsetEntries() async throws -> [MindsetEntry]

    /// Delete all locally persisted user data (profile + journal history).
    /// Used for account deletion and privacy resets.
    func deleteAllUserData() async throws
}
