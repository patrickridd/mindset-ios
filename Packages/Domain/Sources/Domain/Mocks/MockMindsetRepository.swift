//
//  MockMindsetRepository.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import Foundation

public final class MockMindsetRepository: EntryRepository, @unchecked Sendable {

    public var mockEntries: [Entry] = []

    public init(days: Int) {
        let calendar = Calendar.current
        self.mockEntries = (0..<days).map { i in
            let date = calendar.startOfDay(
                for: calendar.date(byAdding: .day, value: -i, to: Date())!)

            return Entry(
                id: UUID(),
                userId: UUID().uuidString,
                dateCreated: date,
                promptResponses: [
                    PromptResponse(
                        promptId: UUID().uuidString, category: .gratitude,
                        userText: "I'm grateful for the progress on my app during day \(i).")
                ],
                archetypeTag: i > 5 ? "The Architect" : "The Student",
                sentimentScore: 8
            )
        }
    }

    public func fetchAllEntries() async throws -> [Entry] {
        mockEntries
    }

    public func save(entry: Entry) async throws {
        mockEntries.append(entry)
    }

    public func fetchLatestEntry() async throws -> Domain.Entry? {
        mockEntries.last
    }

    public func deleteAllEntries() async throws {
        mockEntries = []
    }
}
