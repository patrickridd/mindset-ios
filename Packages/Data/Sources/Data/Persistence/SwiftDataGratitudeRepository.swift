//
//  SwiftDataGratitudeRepository.swift
//  Data
//
//  Created by patrick ridd on 1/2/26.
//

import Domain
import SwiftData
import Foundation

@MainActor
public final class SwiftDataGratitudeRepository: GratitudeRepository {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func fetchEntries() async throws -> [GratitudeEntry] {
        let descriptor = FetchDescriptor<GratitudeEntryDB>(sortBy: [SortDescriptor(\GratitudeEntryDB.date, order: .reverse)])
        let dbEntries = try modelContext.fetch(descriptor)
        
        // Map DB models to Domain entities
        return dbEntries.map { $0.toDomain() }
    }
    
    public func save(_ entry: GratitudeEntry) async throws {
        let dbEntry = GratitudeEntryDB(id: entry.id, date: entry.date, text: entry.text)
        modelContext.insert(dbEntry)
        try modelContext.save()
    }
}

// Inside your Data package
public extension ModelContainer {
    static let preview: ModelContainer = {
        let schema = Schema([GratitudeEntryDB.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
