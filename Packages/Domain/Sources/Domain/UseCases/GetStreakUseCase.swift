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
        // Match the naming convention we used in SDMindsetRepository
        let entries = try await repository.fetchAllEntries()
        
        return calculateStreak(
            from: entries.map { $0.date },
            relativeTo: now
        )
    }
    
    private func calculateStreak(from dates: [Date], relativeTo now: Date) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        
        // 1. Sort dates and remove time components
        let sortedDates = dates
            .map { calendar.startOfDay(for: $0) }
        
        // 2. Unique dates, newest first
        let uniqueDates = Array(Set(sortedDates)).sorted(by: >)
        
        // FIX: Use 'now' instead of 'Date()' for testing and consistency
        let referenceToday = calendar.startOfDay(for: now)
        let referenceYesterday = calendar.date(byAdding: .day, value: -1, to: referenceToday)!
        
        // 3. Check if the streak is still "active"
        guard let mostRecent = uniqueDates.first,
              mostRecent == referenceToday || mostRecent == referenceYesterday else {
            return 0
        }
        
        // 4. Count the consecutive days
        var streak = 0
        var currentDateToCheck = mostRecent
        
        for date in uniqueDates {
            if date == currentDateToCheck {
                streak += 1
                currentDateToCheck = calendar.date(byAdding: .day, value: -1, to: currentDateToCheck)!
            } else {
                break
            }
        }
        
        return streak
    }
}
