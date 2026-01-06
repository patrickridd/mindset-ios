//
//  MockGratitudeRepository.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/5/26.
//

import Domain
import Foundation

public final class MockGratitudeRepository: GratitudeRepository, @unchecked Sendable {
    public var mockEntries: [GratitudeEntry] = []

    public init(days: Int) {
        self.mockEntries = (0..<days).map { i in
            // Use "startOfDay" to avoid time-of-day math issues
            let pastDate = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let cleanDate = Calendar.current.startOfDay(for: pastDate)
            
            return GratitudeEntry(
                id: UUID(),
                date: cleanDate,
                text: "Mock entry \(i)"
            )
        }
    }

    public func fetchEntries() async throws -> [GratitudeEntry] {
        return mockEntries
    }

    public func save(_ entry: GratitudeEntry) async throws {
        mockEntries.append(entry)
    }
}
