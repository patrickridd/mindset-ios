//
//  AddEntryUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

public struct AddEntryUseCase: Sendable {
    private let repository: EntryRepository
    private static let minimumCharsPerSlot = 3

    public init(repository: EntryRepository) {
        self.repository = repository
    }

    public func execute(entry: Entry) async throws {
        // 1. Business Rule: Every slot in every response must meet the minimum length
        let allSlotsValid = entry.promptResponses.allSatisfy { response in
            response.answers.allSatisfy { answer in
                answer.trimmingCharacters(in: .whitespacesAndNewlines).count >= Self.minimumCharsPerSlot
            }
        }

        // 2. Ensure we have at least one response and all are valid
        guard !entry.promptResponses.isEmpty, allSlotsValid else {
            throw DomainError.incompleteRitual
        }

        // 3. Save to the persistent store
        try await repository.save(entry: entry)
    }
}
