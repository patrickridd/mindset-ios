//
//  AddEntryUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

public struct AddEntryUseCase: Sendable {
    private let entryRepository: EntryRepository
    private let userRepository: UserRepository

    public init(entryRepository: EntryRepository, userRepository: UserRepository) {
        self.entryRepository = entryRepository
        self.userRepository = userRepository
    }

    public func execute(entry: Entry) async throws {
        // 1. Validation: Ask the entry if its responses are valid
        // (Note: You could add a 'isValid' property to Entry too)
        guard !entry.promptResponses.isEmpty else {
            throw DomainError.incompleteRitual
        }
        
        guard entry.promptResponses.allSatisfy({ $0.isValid }) else {
            throw DomainError.incompleteRitual
        }

        // 2. Calculate the "Fact" of earned XP
        let earnedXP = RitualGamification.earnedXP(from: entry.promptResponses)
        
        // 3. Create the finalized Entry stamped with points
        let finalizedEntry = Entry(entry: entry, totalXpEarned: earnedXP)

        // 4. Persistence
        // We save the entry first so the 'History' is updated
        try await entryRepository.save(entry: finalizedEntry)
        
        // 5. Update the User's "XP Bucket"
        // This triggers the level-up logic in the User profile
//        try await userRepository.incrementTotalXP(userId: entry.userId, by: earnedXP)
    }
}
