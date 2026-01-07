//
//  DomainError.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//


import Foundation

public enum DomainError: Error, LocalizedError {
    case incompleteRitual
    case persistenceFailure(Error)
    
    public var errorDescription: String? {
        switch self {
        case .incompleteRitual:
            return "A ritual requires Gratitude, a Goal, and an Affirmation to be complete."
        case .persistenceFailure(let error):
            return "We couldn't save your progress: \(error.localizedDescription)"
        }
    }
}
