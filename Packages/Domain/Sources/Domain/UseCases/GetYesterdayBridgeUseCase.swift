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
        
        // Clean, readable, and easy to expand later
        let yesterdayGoal = latest?.responses.first(where: { $0.category.isGoalOriented })
        
        return yesterdayGoal?.userText
    }
}
