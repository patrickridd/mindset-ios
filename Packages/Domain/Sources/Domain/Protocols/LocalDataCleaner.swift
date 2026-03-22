//
//  LocalDataCleaner.swift
//  Domain
//
//  Created by patrick ridd on 3/22/26.
//


/// A specialized interface for data cleanup during logout/reset.
public protocol LocalDataCleaner: Sendable {
    func purgeLocalCache() async throws
}