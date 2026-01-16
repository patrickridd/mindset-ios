//
//  GetYesterdayBridgeUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//


import Foundation

public struct GetYesterdayBridgeUseCase: Sendable {
    private let repository: MindsetRepository
    
    public init(repository: MindsetRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> String? {
        let latest = try await repository.fetchLatestEntry()
        
        // Find the first response that was a "Goal" or "Future Self"
        // This makes the 'Bridge' dynamic!
        let yesterdayGoal = latest?.responses.first(where: {
            $0.category == .futureSelf || $0.category == .bestPossibleSelf
        })
        
        return yesterdayGoal?.userText
    }
}
