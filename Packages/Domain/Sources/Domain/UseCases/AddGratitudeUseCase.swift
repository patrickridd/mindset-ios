//
//  AddGratitudeUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/4/26.
//

import Foundation

public struct AddGratitudeUseCase: Sendable {
    private let repository: GratitudeRepository
    
    public init(repository: GratitudeRepository) {
        self.repository = repository
    }
    
    public func execute(text: String) async throws {
        // Business Rule: Don't save empty entries
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let entry = GratitudeEntry(date: Date(), text: text)
        try await repository.save(entry)
    }
}
