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
                gratitudeText: "I'm grateful for the progress on my app during day \(i).",
                goalText: "Complete the \(i == 1 ? "Yesterday Bridge" : "Data Layer refactor").",
                affirmationText: "I am becoming a world-class architect.",
                archetypeTag: i > 5 ? "The Architect" : "The Student"
            )
        }
    }

    public func fetchEntries() async throws -> [MindsetEntry] {
        return mockEntries
    }

    public func save(_ entry: MindsetEntry) async throws {
        mockEntries.append(entry)
    }
}
