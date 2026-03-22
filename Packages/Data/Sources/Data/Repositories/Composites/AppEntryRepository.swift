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

    public func fetchAllEntries() async throws -> [Entry] {
        let localEntries = try await local.fetchAllEntries()
        
        if syncTask != nil { return localEntries }

        syncTask = Task {
            defer { syncTask = nil }
            
            guard let _ = await authStateQuery.getCurrentUserID() else { return }
            
            do {
                let remoteEntries = try await remote.fetchAllEntries()
                if Task.isCancelled { return }
                
                await reconcile(local: localEntries, remote: remoteEntries)
            } catch {
                logger.log("☁️ Entries Sync failed: \(error.localizedDescription)")
            }
        }
        
        return localEntries
    }

    private func reconcile(local: [Entry], remote: [Entry]) async {
        // 1. Create maps for quick lookup
        let localMap = Dictionary(uniqueKeysWithValues: local.map { ($0.id, $0) })
        let remoteMap = Dictionary(uniqueKeysWithValues: remote.map { ($0.id, $0) })
        
        var hasChanges = false

        // 2. Identify entries in Remote but NOT in Local (New from other devices)
        for remoteEntry in remote {
            if let localMatch = localMap[remoteEntry.id] {
                // If both exist, check which is newer (Conflict Resolution)
                if remoteEntry.lastUpdatedAt > localMatch.lastUpdatedAt {
                    try? await self.local.save(entry: remoteEntry)
                    hasChanges = true
                }
            } else {
                // Completely missing locally
                try? await self.local.save(entry: remoteEntry)
                hasChanges = true
            }
        }

        // 3. Identify entries in Local but NOT in Remote (Offline saves needing upload)
        for localEntry in local {
            if remoteMap[localEntry.id] == nil {
                try? await self.remote.save(entry: localEntry)
                // No 'hasChanges' here because local UI is already up to date
            }
        }

        // 4. Notify UI if we pulled down new data
        if hasChanges {
            notificationCenter.post(name: .databaseDidChange, object: nil)
        }
    }
    
    public func save(entry: Entry) async throws {
        syncTask?.cancel()
        syncTask = nil

        var updatedEntry = entry
        updatedEntry.lastUpdatedAt = Date()

        try await local.save(entry: updatedEntry)

        Task {
            try? await remote.save(entry: updatedEntry)
        }
    }
    
    public func fetchLatestEntry() async throws -> Entry? {
        try await local.fetchAllEntries().first
    }

    public func deleteAllEntries() async throws {
        try await local.deleteAllEntries()
        try await remote.deleteAllEntries()
    }
}
