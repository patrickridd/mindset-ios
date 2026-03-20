//
//  AddMindsetUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

public struct AddMindsetUseCase: Sendable {
    private let repository: MindsetEntryRepository

    public init(repository: MindsetEntryRepository) {
        self.repository = repository
    }

    public func execute(entry: MindsetEntry) async throws {
        let totalCharacters = entry.promptResponses.reduce(0) { $0 + $1.userText.count }

        // Business Rule: Ensure the user actually wrote something in their responses
        guard totalCharacters > 9 else {
            throw DomainError.incompleteRitual
        }

        try await repository.addEntry(entry)
    }
}
