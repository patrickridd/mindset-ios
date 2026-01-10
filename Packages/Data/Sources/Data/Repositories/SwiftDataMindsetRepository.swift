//
//  SwiftDataMindsetRepository.swift
//  Data
//
//  Created by patrick ridd on 1/6/26.
//

import Foundation
import SwiftData
import Domain

@MainActor
public final class SwiftDataMindsetRepository: MindsetRepository {
    private let persistence: PersistenceService

    public init(persistence: PersistenceService) {
        self.persistence = persistence
    }

    public func getLatestEntry() async throws -> MindsetEntry? {
        // We'll fetch all and get the last one, or add a specific fetch to Persistence
        let entries = try await persistence.fetchAllMindsetEntries()
        return entries.sorted(by: { $0.date > $1.date }).first
    }

    public func fetchEntries() async throws -> [MindsetEntry] {
        return try await persistence.fetchAllMindsetEntries()
    }

    public func save(_ entry: MindsetEntry) async throws {
        try await persistence.saveMindsetEntry(entry)
    }
}
