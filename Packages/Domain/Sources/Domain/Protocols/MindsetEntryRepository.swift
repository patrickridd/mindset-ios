//
//  MindsetEntryRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

public protocol MindsetEntryRepository: Sendable {
    func fetchLatestEntry() async throws -> MindsetEntry?
    func fetchAllEntries() async throws -> [MindsetEntry]
    func addEntry(_ entry: MindsetEntry) async throws
}
