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
        let latest = try await repository.getLatestEntry()
        return latest?.goalText
    }
}
