//
//  GetStreakUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

import Foundation

/// A utility for calculating consecutive daily activity streaks.
///
/// This calculator is agnostic of data sources and operates purely on `Date` arrays,
/// making it highly testable. It considers a streak "active" if there is an entry
/// for today or yesterday.
public struct StreakCalculator: Sendable {
    
    /// Calculates the number of consecutive days of activity leading up to a reference date.
    ///
    /// The algorithm follows these steps:
    /// 1. Normalizes all dates to the start of their respective days.
    /// 2. Filters for unique dates and sorts them in descending order.
    /// 3. Validates that the most recent entry is either today or yesterday.
    /// 4. Iterates backwards to count uninterrupted consecutive days.
    ///
    /// - Parameters:
    ///   - dates: An array of `Date` objects representing user activity/entries.
    ///   - now: The reference date to calculate from (defaults to the current moment).
    /// - Returns: The total number of consecutive days. Returns `0` if no entries exist
    ///   or if the streak has been broken (no entry today or yesterday).
    static func calculateStreak(from dates: [Date], relativeTo now: Date) -> Int {
        guard !dates.isEmpty else { return 0 }

        let calendar = Calendar.current

        // 1. Sort dates and remove time components
        let sortedDates =
            dates
            .map { calendar.startOfDay(for: $0) }

        // 2. Unique dates, newest first
        let uniqueDates = Array(Set(sortedDates)).sorted(by: >)

        // FIX: Use 'now' instead of 'Date()' for testing and consistency
        let referenceToday = calendar.startOfDay(for: now)
        let referenceYesterday = calendar.date(byAdding: .day, value: -1, to: referenceToday)!

        // 3. Check if the streak is still "active"
        guard let mostRecent = uniqueDates.first,
            mostRecent == referenceToday || mostRecent == referenceYesterday
        else {
            return 0
        }

        // 4. Count the consecutive days
        var streak = 0
        var currentDateToCheck = mostRecent

        for date in uniqueDates {
            if date == currentDateToCheck {
                streak += 1
                currentDateToCheck = calendar.date(
                    byAdding: .day, value: -1, to: currentDateToCheck)!
            } else {
                break
            }
        }

        return streak
    }
}

/// A Use Case that retrieves and calculates the user's current mindset entry streak.
///
/// This service orchestrates the fetching of data from the `MindsetRepository` and
/// leverages the ``StreakCalculator`` to determine the numerical streak value.
///
/// Use this in ViewModels to display gamified progress or to trigger streak-based rewards.
public struct GetStreakUseCase: Sendable {
    private let repository: EntryRepository
    
    /// Creates a new GetStreakUseCase.
    /// - Parameter repository: The repository used to fetch ``MindsetEntry`` history.
    public init(repository: EntryRepository) {
        self.repository = repository
    }

    /// Fetches all entries and computes the current streak.
    ///
    /// - Parameter now: The date to use as "today" for the calculation. Defaults to `Date()`.
    /// - Returns: The current streak count as an `Int`.
    /// - Throws: An error if the repository fails to fetch entries.
    public func execute(relativeTo now: Date = Date()) async throws -> Int {
        // Match the naming convention we used in SDMindsetRepository
        let entries = try await repository.fetchAllEntries()

        return StreakCalculator.calculateStreak(
            from: entries.map { $0.dateCreated },
            relativeTo: now
        )
    }

}
