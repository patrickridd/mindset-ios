//
//  EntryRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

public protocol EntryRepository: Sendable {
    func fetchLatestEntry() async throws -> Entry?
    func fetchAllEntries() async throws -> [Entry]
    func deleteAllEntries() async throws
    func save(entry: Entry) async throws
}
