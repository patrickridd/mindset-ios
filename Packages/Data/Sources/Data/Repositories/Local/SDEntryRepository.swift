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
    
    private let modelContext: ModelContext
    private let logger: AppLogger
    private let notificationCenter: NotificationCenter

    public init(modelContext: ModelContext, logger: AppLogger, notificationCenter: NotificationCenter = .default) {
        self.modelContext = modelContext
        self.logger = logger
        self.notificationCenter = notificationCenter
    }

    public func fetchAllEntries() async throws -> [Entry] {
        let descriptor = FetchDescriptor<SDEntry>(sortBy: [
            SortDescriptor(\SDEntry.dateCreated, order: .reverse)
        ])
        let dbEntries = try modelContext.fetch(descriptor)
        return dbEntries.map { $0.toDomain() }
    }

    public func fetchLatestEntry() async throws -> Entry? {
        try await fetchAllEntries().first
    }

    public func save(entry: Entry) async throws {
        let entryId = entry.id
        let descriptor = FetchDescriptor<SDEntry>(
            predicate: #Predicate<SDEntry> { $0.id == entryId }
        )
        
        if let existingEntry = try modelContext.fetch(descriptor).first {
            // Update the existing tracked object
            existingEntry.update(from: entry, in: modelContext)
            logger.log("✅ Updated `SDEntry`")
        } else {
            // Create new
            let newSD = SDEntry.fromDomain(entry)
            modelContext.insert(newSD)
            logger.log("✅ Created/Saved `SDEntry`")
        }
        
        try modelContext.save()
        notificationCenter.post(name: .databaseDidChange, object: nil)
    }

    public func deleteAllEntries() async throws {
        try modelContext.delete(model: SDEntry.self)
        try modelContext.save()
    }
}

extension SDEntryRepository: LocalDataCleaner {
    public func purgeLocalCache() async throws {
        try await deleteAllEntries()
    }
}
