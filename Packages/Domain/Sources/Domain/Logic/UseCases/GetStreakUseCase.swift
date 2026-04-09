//
//  GetStreakUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

import Foundation

/// A Use Case that retrieves and calculates the user's current mindset entry streak.
///
/// This service orchestrates the fetching of data from the ``EntryRepository`` and
/// leverages the ``StreakCalculator`` to determine the numerical streak value.
///
/// Use this in ViewModels to display gamified progress or to trigger streak-based rewards.
public struct GetStreakUseCase: Sendable {
    private let repository: EntryRepository
    
    /// Creates a new GetStreakUseCase.
    /// - Parameter repository: The repository used to fetch ``Entry`` history.
    public init(repository: EntryRepository) {
        self.repository = repository
    }

    /// Fetches all entries and computes the current streak.
    ///
    /// - Parameter now: The date to use as "today" for the calculation. Defaults to `Date()`.
    /// - Returns: The current streak count as an `Int`.
    /// - Throws: An error if the repository fails to fetch entries.
    public func execute(relativeTo now: Date = Date()) async throws -> Int {
        // Match the naming convention we used in SDEntryRepository
        let entries = try await repository.fetchAllEntries()

        return StreakCalculator.calculateStreak(
            from: entries.map { $0.dateCreated },
            relativeTo: now
        )
    }

}
