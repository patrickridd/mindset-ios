//
//  MindsetHistoryViewModel.swift
//  FeatureHistory
//
//  Created by patrick ridd on 1/18/26.
//

import Domain
import Foundation
import Observation

@Observable
public final class MindsetHistoryViewModel {
    private let repository: MindsetEntryRepository
    private let logger: AppLogger
    public var entries: [MindsetEntry] = []
    public var isLoading = false

    public init(repository: MindsetEntryRepository, logger: AppLogger) {
        self.repository = repository
        self.logger = logger
    }

    public func fetchHistory() async {
        isLoading = true
        do {
            self.entries = try await repository.fetchAllEntries()
        } catch {
            logger.log("❌ History load failed: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
