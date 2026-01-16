//
//  GratitudeRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

public protocol MindsetRepository: Sendable {
    func fetchLatestEntry() async throws -> MindsetEntry?
    func fetchEntries() async throws -> [MindsetEntry]
    func addEntry(_ entry: MindsetEntry) async throws
}
