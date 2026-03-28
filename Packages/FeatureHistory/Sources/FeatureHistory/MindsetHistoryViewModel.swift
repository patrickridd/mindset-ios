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
    private let entryRepository: EntryRepository
    private let logger: AppLogger
    public var entries: [Entry] = []
    public var isLoading = false

    public init(entryRepository: EntryRepository, logger: AppLogger) {
        self.entryRepository = entryRepository
        self.logger = logger
    }

    public func fetchHistory() async {
        isLoading = true
        do {
            self.entries = try await entryRepository.fetchAllEntries()
        } catch {
            logger.log("❌ History load failed: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
