//
//  GratitudeRepository.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

public protocol GratitudeRepository: Sendable {
    func fetchEntries() async throws -> [GratitudeEntry]
    func save(_ entry: GratitudeEntry) async throws
}
