//
//  AppEntryRepository.swift
//  Data
//
//  Created by patrick ridd on 3/19/26.
//

import Domain
import Foundation

@MainActor
public final class AppEntryRepository: EntryRepository {

    private let local: EntryRepository
    private let remote: EntryRepository
    private let authStateQuery: AuthStateQuery
    private let logger: AppLogger
    private let notificationCenter: NotificationCenter
    
    private var syncTask: Task<Void, Never>?

    public init(local: EntryRepository, remote: EntryRepository, authStateQuery: AuthStateQuery, logger: AppLogger, notificationCenter: NotificationCenter = .default) {
        self.local = local
        self.remote = remote
        self.authStateQuery = authStateQuery
        self.logger = logger
        self.notificationCenter = notificationCenter
    }

    /// Fetches from local repo ONLY because our local storage will be synced with remote when initialy saving and when we launch/pull to refresh via ``AppSyncService``.
    public func fetchAllEntries() async throws -> [Entry] {
        try await local.fetchAllEntries()
    }

    public func save(entry: Entry) async throws {
        var updatedEntry = entry
        updatedEntry.lastUpdatedAt = Date()
        
        try await local.save(entry: updatedEntry)
        
        // Fire and forget to the cloud
        Task { try? await remote.save(entry: updatedEntry) }
    }
    
    public func fetchLatestEntry() async throws -> Entry? {
        try await local.fetchAllEntries().first
    }

    public func deleteAllEntries() async throws {
        try await local.deleteAllEntries()
        try await remote.deleteAllEntries()
    }
}
