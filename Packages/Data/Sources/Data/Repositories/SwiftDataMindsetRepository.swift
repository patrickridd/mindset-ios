//
//  SwiftDataMindsetRepository.swift
//  Data
//
//  Created by patrick ridd on 1/6/26.
//


// Data/Sources/Data/Repositories/SwiftDataMindsetRepository.swift
import Foundation
import SwiftData
import Domain

@MainActor
public final class SwiftDataMindsetRepository: MindsetRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchEntries() async throws -> [MindsetEntry] {
        let descriptor = FetchDescriptor<MindsetEntryDB>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let dbEntries = try modelContext.fetch(descriptor)
        return dbEntries.map { $0.toDomain() }
    }

    public func save(_ entry: MindsetEntry) async throws {
        let dbEntry = MindsetEntryDB(
            id: entry.id,
            date: entry.date,
            gratitudeText: entry.gratitudeText,
            goalText: entry.goalText,
            affirmationText: entry.affirmationText,
            archetypeTag: entry.archetypeTag,
            sentimentScore: entry.sentimentScore
        )
        modelContext.insert(dbEntry)
        try modelContext.save()
    }
}