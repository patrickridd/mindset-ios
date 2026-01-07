//
//  GratitudeRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

public protocol MindsetRepository: Sendable {
    func fetchEntries() async throws -> [MindsetEntry]
    func save(_ entry: MindsetEntry) async throws
}
