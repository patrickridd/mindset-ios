//
//  GetStreakUseCaseTests.swift
//  Domain
//
//  Created by patrick ridd on 1/3/26.
//

import Domain
import Testing
import Foundation

@MainActor
struct GetStreakUseCaseTests {

    @Test func execute_returns_empty() async throws {
        let repository: GratitudeRepository = GratitudeRepositoryStub()
        let useCase = GetStreakUseCase(repository: repository)
        
        let result = try await useCase.execute()
        
        #expect(result == 0)
    }

    @Test func execute_returns_correct_value() async throws {
        let repository = GratitudeRepositoryStub()
        let entry = GratitudeEntry(text: "entry")
        repository.fetchedEntries = [entry]
        let useCase = GetStreakUseCase(repository: repository)
        
        try await #expect(useCase.execute() == 1)
    }

    @Test func execute_returns_one_when_there_is_a_gap() async throws {
        let repository = GratitudeRepositoryStub()
        let startOfToday: Date = .startOfToday()
        
        // Missing "yesterday"
        repository.fetchedEntries = [
            GratitudeEntry(date: startOfToday, text: "today"),
            GratitudeEntry(date: .daysAgo(2), text: "gap day")
        ]
        
        let useCase = GetStreakUseCase(repository: repository)
        let result = try await useCase.execute(relativeTo: startOfToday)
        
        #expect(result == 1) // Streak is only the most recent consecutive string
    }

    @Test func execute_returns_three_day_streak() async throws {
        let repository = GratitudeRepositoryStub()

        // 3 days in a row including today
        repository.fetchedEntries = [
            GratitudeEntry(date: .startOfToday(), text: "today"),
            GratitudeEntry(date: .daysAgo(1), text: "yesterday"),
            GratitudeEntry(date: .daysAgo(2), text: "two days ago")
        ]
        
        let useCase = GetStreakUseCase(repository: repository)
        let result = try await useCase.execute(relativeTo: .startOfToday())
        
        #expect(result == 3)
    }
    
    @Test func execute_returns_three_day_streak_when_today_isStillPending() async throws {
        let repository = GratitudeRepositoryStub()
        
        // 3 days in a row excluding today's pending entry
        repository.fetchedEntries = [
            GratitudeEntry(date: .daysAgo(1), text: "yesterday"),
            GratitudeEntry(date: .daysAgo(2), text: "two days ago"),
            GratitudeEntry(date: .daysAgo(3), text: "three days ago")
        ]
        
        let useCase = GetStreakUseCase(repository: repository)
        let result = try await useCase.execute(relativeTo: .startOfToday())
        
        #expect(result == 3)
    }

    @Test func execute_returns_zero_after_missing_day() async throws {
        let repository = GratitudeRepositoryStub()
        
        // Missed yesterday and today
        repository.fetchedEntries = [
            GratitudeEntry(date: .daysAgo(2), text: "two days ago"),
            GratitudeEntry(date: .daysAgo(3), text: "three days ago"),
            GratitudeEntry(date: .daysAgo(4), text: "four days ago")
        ]
        
        let useCase = GetStreakUseCase(repository: repository)
        let result = try await useCase.execute(relativeTo: .startOfToday())
        
        #expect(result == 0)
    }

    @Test func execute_returns_one_after_restarting_streak() async throws {
        let repository = GratitudeRepositoryStub()
        
        // Missed yesterday
        repository.fetchedEntries = [
            GratitudeEntry(date: .startOfToday(), text: "Today"),
            GratitudeEntry(date: .daysAgo(2), text: "two days ago"),
            GratitudeEntry(date: .daysAgo(3), text: "three days ago"),
            GratitudeEntry(date: .daysAgo(4), text: "four days ago")
        ]
        
        let useCase = GetStreakUseCase(repository: repository)
        let result = try await useCase.execute(relativeTo: .startOfToday())
        
        #expect(result == 1)
    }
    
    // MARK: Helpers
    @MainActor
    private class GratitudeRepositoryStub: GratitudeRepository {
        
        var fetchedEntries: [Domain.GratitudeEntry] = []
        var savedEntry: Domain.GratitudeEntry?
        
        func fetchEntries() async throws -> [Domain.GratitudeEntry] {
            fetchedEntries
        }
        
        func save(_ entry: Domain.GratitudeEntry) async throws {
            savedEntry = entry
        }
    }
}

extension Date {
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }
    
    static func startOfToday() -> Date {
        Calendar.current.startOfDay(for: Date())
    }
}
