//
//  AddMindsetUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//


public struct AddMindsetUseCase: Sendable {
    private let repository: MindsetRepository
    
    public init(repository: MindsetRepository) {
        self.repository = repository
    }
    
    // We pass in the "Triple" required for the Morning Ritual
    public func execute(
        gratitude: String,
        goal: String,
        affirmation: String
    ) async throws {
        // Business Rule: A ritual is only valid if all parts are present
        // This enforces the "Identity" building aspect at the logic level
        guard !gratitude.isEmpty, !goal.isEmpty, !affirmation.isEmpty else {
            throw DomainError.incompleteRitual
        }
        
        let entry = MindsetEntry(
            gratitudeText: gratitude,
            goalText: goal,
            affirmationText: affirmation
        )
        
        try await repository.save(entry)
    }
}
