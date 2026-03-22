//
//  AppMindsetEntryRepository.swift
//  Data
//
//  Created by patrick ridd on 3/19/26.
//

import Domain

public final class AppMindsetEntryRepository: EntryRepository {
    private let local: EntryRepository
    private let remote: EntryRepository
    private let authStateQuery: AuthStateQuery // To get the current UID

    public init(local: EntryRepository, remote: EntryRepository, authStateQuery: AuthStateQuery) {
        self.local = local
        self.remote = remote
        self.authStateQuery = authStateQuery
    }

    public func save(entry: Entry) async throws {
        // 1. Instant UI: Save to SwiftData
        try await local.save(entry: entry)
        
        // 2. Background Sync: Push to Firebase
        Task {
            try? await remote.save(entry: entry)
        }
    }

    public func fetchAllEntries() async throws -> [Entry] {
        // 1. Return local immediately
        let localEntries = try await local.fetchAllEntries()

        // 2. Optional: Trigger a background fetch from remote to 
        // see if there's data from other devices
        if let uid = await authStateQuery.getCurrentUserID() {
            Task {
                let remoteEntries = try? await remote.fetchAllEntries()
                // Here you would run your 'Comparison/Sync' logic
                // using lastUpdatedAt if needed
            }
        }
        
        return localEntries
    }
    
    public func fetchLatestEntry() async throws -> Entry? {
        try await local.fetchAllEntries().first
    }

    public func deleteAllEntries() async throws {
        try await local.deleteAllEntries()
        
        
    }
}
