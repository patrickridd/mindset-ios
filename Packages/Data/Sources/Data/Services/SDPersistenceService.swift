//
//  SwiftDataPersistenceService.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import Domain
import Foundation
import SwiftData

@MainActor
public final class SDPersistenceService: PersistenceService {

    private let modelContext: ModelContext
    private let logger: AppLogger

    public init(modelContext: ModelContext, logger: AppLogger) {
        self.modelContext = modelContext
        self.logger = logger
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        let userId = profile.id
        let descriptor = FetchDescriptor<SDUserProfile>(
            predicate: #Predicate<SDUserProfile> { $0.id == userId }
        )
        
        // Check if the object already exists in the database
        if let existingUser = try modelContext.fetch(descriptor).first {
            logger.log("Updating **existing** `SDUserProfile`")
            existingUser.update(from: profile)
        } else {
            let newUser = SDUserProfile.fromDomain(profile)
            logger.log("Creating **NEW** `SDUserProfile`")
            
            modelContext.insert(newUser)
        }
        
        try modelContext.save()
        logger.log("✅ Saved `SDUserProfile`")
    }

    /// Fetches `SDUserProfile` and map the @Model back to our Domain `UserProfile`
    public func fetchUserProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<SDUserProfile>()
        return try modelContext.fetch(descriptor).first?.toDomain()
    }
    
    public func saveEntry(_ entry: MindsetEntry) async throws {
        let entryId = entry.id
        let descriptor = FetchDescriptor<SDMindsetEntry>(
            predicate: #Predicate<SDMindsetEntry> { $0.id == entryId }
        )
        
        if let existingEntry = try modelContext.fetch(descriptor).first {
            // Update the existing tracked object
            existingEntry.update(from: entry, in: modelContext)
        } else {
            // Create new
            let newSD = SDMindsetEntry.fromDomain(entry)
            modelContext.insert(newSD)
        }
        
        try modelContext.save()
    }

    public func fetchAllMindsetEntries() async throws -> [Domain.MindsetEntry] {
        let descriptor = FetchDescriptor<SDMindsetEntry>(sortBy: [
            SortDescriptor(\SDMindsetEntry.date, order: .reverse)
        ])
        let dbEntries = try modelContext.fetch(descriptor)
        return dbEntries.map { $0.toDomain() }
    }

    public func deleteAllUserData() async throws {
        let profileDescriptor = FetchDescriptor<SDUserProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        for profile in profiles {
            modelContext.delete(profile)
        }

        let entryDescriptor = FetchDescriptor<SDMindsetEntry>()
        let entries = try modelContext.fetch(entryDescriptor)
        for entry in entries {
            modelContext.delete(entry)
        }

        try modelContext.save()
    }
}
