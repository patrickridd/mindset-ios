//
//  AppMindsetEntryRepository.swift
//  Data
//
//  Created by patrick ridd on 3/19/26.
//

import Domain

public final class AppMindsetEntryRepository: MindsetEntryRepository {
    private let local: MindsetEntryRepository
    private let remote: RemoteMindsetEntryRepository
    private let authStateQuery: AuthStateQuery // To get the current UID

    public init(local: MindsetEntryRepository, remote: RemoteMindsetEntryRepository, authStateQuery: AuthStateQuery) {
        self.local = local
        self.remote = remote
        self.authStateQuery = authStateQuery
    }

    public func addEntry(_ entry: MindsetEntry) async throws {
        // 1. Instant UI: Save to SwiftData
        try await local.addEntry(entry)
        
        // 2. Background Sync: Push to Firebase
        Task {
            try? await remote.uploadEntry(entry)
        }
    }

    public func fetchAllEntries() async throws -> [MindsetEntry] {
        // 1. Return local immediately
        let localEntries = try await local.fetchAllEntries()

        // 2. Optional: Trigger a background fetch from remote to 
        // see if there's data from other devices
        if let uid = await authStateQuery.getCurrentUserID() {
            Task {
                let remoteEntries = try? await remote.fetchEntries(userId: uid)
                // Here you would run your 'Comparison/Sync' logic 
                // using lastUpdatedAt if needed
            }
        }
        
        return localEntries
    }
    
    public func fetchLatestEntry() async throws -> MindsetEntry? {
        try await local.fetchAllEntries().first
    }
}
