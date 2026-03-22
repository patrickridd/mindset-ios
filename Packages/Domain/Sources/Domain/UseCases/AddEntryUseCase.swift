//
//  AddEntryUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

public struct AddEntryUseCase: Sendable {
    private let repository: EntryRepository

    public init(repository: EntryRepository) {
        self.repository = repository
    }

    public func execute(entry: Entry) async throws {
        let totalCharacters = entry.promptResponses.reduce(0) { $0 + $1.userText.count }

        // Business Rule: Ensure the user actually wrote something in their responses
        guard totalCharacters > 9 else {
            throw DomainError.incompleteRitual
        }

        try await repository.save(entry: entry)
    }
}
