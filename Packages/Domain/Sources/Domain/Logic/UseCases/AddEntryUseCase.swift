//
//  AddEntryUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

public struct AddEntryUseCase: Sendable {
    private let entryRepository: EntryRepository
    private let statsRepository: UserStatsRepository

    public init(entryRepository: EntryRepository, statsRepository: UserStatsRepository) {
        self.entryRepository = entryRepository
        self.statsRepository = statsRepository
    }

    public func execute(entry: Entry) async throws {
        // 1. Validate
        guard entry.promptResponses.allSatisfy({ $0.isValid }) else {
            throw DomainError.invalidResponse
        }

        // 2. XP Logic
        let earnedXP = RitualGamification.earnedXP(from: entry.promptResponses)
        let finalizedEntry = Entry(entry: entry, totalXpEarned: earnedXP)

        // 3. Save Entry
        try await entryRepository.save(entry: finalizedEntry)

        // 4. Update Stats (The Scale-Friendly Way)
        // First, calculate the new streak
        let allEntries = try await entryRepository.fetchAllEntries()
        let newStreak = StreakCalculator.calculateStreak(
            from: allEntries.map { $0.dateCreated },
            relativeTo: finalizedEntry.dateCreated
        )

        // Update the "Bucket" with both XP and the new Streak
        try await statsRepository.incrementTotalXP(userId: entry.userId, by: earnedXP)
        try await statsRepository.updateStreak(userId: entry.userId, newStreak: newStreak)
    }
}
