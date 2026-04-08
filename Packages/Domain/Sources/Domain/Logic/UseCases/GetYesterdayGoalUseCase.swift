//
//  GetYesterdayGoalUseCase.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//

import Foundation

public struct GetYesterdayGoalUseCase: Sendable {
    private let repository: EntryRepository

    public init(repository: EntryRepository) {
        self.repository = repository
    }

    public func execute() async throws -> String? {
        let latest = try await repository.fetchLatestEntry()

        // Clean, readable, and easy to expand later
        let yesterdayGoal = latest?.promptResponses.first(where: { $0.category.isGoalOriented })

        return yesterdayGoal?.answers.first
    }
}
