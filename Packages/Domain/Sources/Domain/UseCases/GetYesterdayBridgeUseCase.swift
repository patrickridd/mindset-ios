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
        let entries = try await repository.fetchEntries()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 1. Sort by date (most recent first)
        // 2. Find the first entry that happened BEFORE today
        let yesterdayEntry = entries
            .sorted { $0.date > $1.date }
            .first { calendar.startOfDay(for: $0.date) < today }
            
        // In your strategy, the "Bridge" pulls the "Goal" from yesterday
        // to see if they achieved it or want to continue it.
        return yesterdayEntry?.goalText
    }
}
