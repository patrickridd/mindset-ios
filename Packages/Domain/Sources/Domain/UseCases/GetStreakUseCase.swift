//
//  GetStreakUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

import Foundation

public struct GetStreakUseCase: Sendable {
    private let repository: MindsetRepository
    
    public init(repository: MindsetRepository) {
        self.repository = repository
    }
    
    public func execute(relativeTo now: Date = Date()) async throws -> Int {
        let entries = try await repository.fetchEntries()
        return calculateStreak(
            from: entries.map { $0.date },
            relativeTo: now
        )
    }
    
    private func calculateStreak(from dates: [Date], relativeTo now: Date) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        // 1. Sort dates descending (newest first) and remove time components
        let calendar = Calendar.current
        let sortedDates = dates
            .map { calendar.startOfDay(for: $0) }
            .sorted(by: >)
        
        // 2. Remove duplicates (if user made two entries in one day)
        let uniqueDates = Array(Set(sortedDates)).sorted(by: >)
        
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // 3. Check if the streak is still "active"
        // (Last entry must be today or yesterday)
        guard let mostRecent = uniqueDates.first,
              mostRecent == today || mostRecent == yesterday else {
            return 0
        }
        
        // 4. Count the consecutive days
        var streak = 0
        var currentDateToCheck = mostRecent
        
        for date in uniqueDates {
            if date == currentDateToCheck {
                streak += 1
                // Move our target to the previous day
                currentDateToCheck = calendar.date(byAdding: .day, value: -1, to: currentDateToCheck)!
            } else {
                // We hit a gap!
                break
            }
        }
        
        return streak
    }
}
