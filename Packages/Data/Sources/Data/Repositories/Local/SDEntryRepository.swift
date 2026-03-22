//
//  SDEntryRepository.swift
//  Data
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import Foundation
import SwiftData

@MainActor
public final class SDEntryRepository: EntryRepository {
    
    private let persistence: PersistenceService

    public init(persistence: PersistenceService) {
        self.persistence = persistence
    }

    public func fetchLatestEntry() async throws -> Entry? {
        try await persistence.fetchAllMindsetEntries().first
    }

    public func fetchAllEntries() async throws -> [Entry] {
        return try await persistence.fetchAllMindsetEntries()
    }

    public func save(entry: Entry) async throws {
        try await persistence.saveEntry(entry)
    }

    public func deleteAllEntries() async throws {
        try await persistence.deleteAllLocalUserData()
    }
}
