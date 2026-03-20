//
//  RemoteMindsetRepository.swift
//  Domain
//
//  Created by patrick ridd on 3/19/26.
//

/// A specialized repository for handling remote operations concerning our ``MindsetEntry``.
public protocol RemoteMindsetEntryRepository: Sendable {
    /// Uploads the local ``MindsetEntry`` to remote Entry.
    func uploadEntry(_ entry: MindsetEntry) async throws
    /// Fetches the entries from backend using the user's authenticated UID.
    func fetchEntries(userId: String) async throws -> [MindsetEntry]
}
