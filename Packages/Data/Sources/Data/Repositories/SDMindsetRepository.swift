//
//  SwiftDataMindsetRepository.swift
//  Data
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import Foundation
import SwiftData

@MainActor
public final class SDMindsetRepository: MindsetRepository {
    private let persistence: PersistenceService

    public init(persistence: PersistenceService) {
        self.persistence = persistence
    }

    public func fetchLatestEntry() async throws -> MindsetEntry? {
        try await persistence.fetchAllMindsetEntries().first
    }

    public func fetchAllEntries() async throws -> [MindsetEntry] {
        return try await persistence.fetchAllMindsetEntries()
    }

    public func addEntry(_ entry: MindsetEntry) async throws {
        try await persistence.saveEntry(entry)
    }
}
