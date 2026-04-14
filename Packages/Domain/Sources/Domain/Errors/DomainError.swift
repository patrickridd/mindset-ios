//
//  DomainError.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

import Foundation

public enum DomainError: Error, LocalizedError {
    case invalidResponse
    case persistenceFailure(Error)
    case userNotFound
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "A valid response requires 3 characters or more"
        case .persistenceFailure(let error):
            return "We couldn't save your progress: \(error.localizedDescription)"
        case .userNotFound:
            return "We couldn't find a user. Please try again."
        }
    }
}
