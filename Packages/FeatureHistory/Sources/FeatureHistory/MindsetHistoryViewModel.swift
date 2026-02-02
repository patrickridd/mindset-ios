//
//  MindsetHistoryViewModel.swift
//  FeatureHistory
//
//  Created by patrick ridd on 1/18/26.
//

import Domain
import Observation
import Foundation
import SharedUtils
import SharedUtils

@Observable
@MainActor
public final class MindsetHistoryViewModel {
    private let repository: MindsetRepository
    public var entries: [MindsetEntry] = []
    public var isLoading = false

    public init(repository: MindsetRepository) {
        self.repository = repository
    }

    public func fetchHistory() async {
        isLoading = true
        do {
            self.entries = try await repository.fetchAllEntries()
        } catch {
            DebugLogger.shared.add("❌ History load failed: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
