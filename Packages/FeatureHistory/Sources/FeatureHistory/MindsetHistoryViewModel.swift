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
    private let syncService: AppSyncService
    private let logger: AppLogger
    public var entries: [Entry] = []
    public var isLoading = false

    public init(entryRepository: EntryRepository, syncService: AppSyncService, logger: AppLogger) {
        self.entryRepository = entryRepository
        self.syncService = syncService
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

    public func pulledToRefresh() async {
        isLoading = true
        await syncService.syncAllData()
        await fetchHistory()
        isLoading = false
    }
}
