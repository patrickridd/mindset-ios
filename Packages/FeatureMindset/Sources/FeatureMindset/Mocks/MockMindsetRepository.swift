//
//  MockMindsetRepository.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import Foundation

public final class MockMindsetRepository: MindsetRepository, @unchecked Sendable {

    public var mockEntries: [MindsetEntry] = []

    public init(days: Int) {
        let calendar = Calendar.current
        self.mockEntries = (0..<days).map { i in
            let date = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -i, to: Date())!)
            
            return MindsetEntry(
                id: UUID(),
                date: date,
                responses: [],
                archetypeTag: i > 5 ? "The Architect" : "The Student",
                sentimentScore: nil
            )
        }
    }

    public func fetchEntries() async throws -> [MindsetEntry] {
        mockEntries
    }

    public func save(_ entry: MindsetEntry) async throws {
        mockEntries.append(entry)
    }

    public func getLatestEntry() async throws -> Domain.MindsetEntry? {
        mockEntries.last
    }
}
