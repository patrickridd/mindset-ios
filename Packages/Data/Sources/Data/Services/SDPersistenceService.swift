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
    private let notificationCenter: NotificationCenter

    public init(modelContext: ModelContext, logger: AppLogger, notificationCenter: NotificationCenter = .default) {
        self.modelContext = modelContext
        self.logger = logger
        self.notificationCenter = notificationCenter
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        let userId = profile.id
        let descriptor = FetchDescriptor<SDUserProfile>(
            predicate: #Predicate<SDUserProfile> { $0.id == userId }
        )
        
        // Check if the object already exists in the database
        if let existingUser = try modelContext.fetch(descriptor).first {
            logger.log("👤 Updating **Existing** `SDUserProfile`")
            existingUser.update(from: profile)
        } else {
            let newUser = SDUserProfile.fromDomain(profile)
            logger.log("👤 Creating **NEW** `SDUserProfile`")
            
            modelContext.insert(newUser)
        }
        
        try modelContext.save()
        logger.log("✅ Saved `SDUserProfile`")
        notificationCenter.post(name: .databaseDidChange, object: nil)
    }

    /// Fetches `SDUserProfile` and map the @Model back to our Domain `UserProfile`
    public func fetchUserProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<SDUserProfile>()
        return try modelContext.fetch(descriptor).first?.toDomain()
    }
    
    public func saveEntry(_ entry: Entry) async throws {
        let entryId = entry.id
        let descriptor = FetchDescriptor<SDMindsetEntry>(
            predicate: #Predicate<SDMindsetEntry> { $0.id == entryId }
        )
        
        if let existingEntry = try modelContext.fetch(descriptor).first {
            // Update the existing tracked object
            existingEntry.update(from: entry, in: modelContext)
            logger.log("✅ Updated `SDMindsetEntry`")
        } else {
            // Create new
            let newSD = SDMindsetEntry.fromDomain(entry)
            modelContext.insert(newSD)
            logger.log("✅ Created/Saved `SDMindsetEntry`")
        }
        
        try modelContext.save()
        notificationCenter.post(name: .databaseDidChange, object: nil)
    }

    public func fetchAllMindsetEntries() async throws -> [Domain.Entry] {
        let descriptor = FetchDescriptor<SDMindsetEntry>(sortBy: [
            SortDescriptor(\SDMindsetEntry.dateCreated, order: .reverse)
        ])
        let dbEntries = try modelContext.fetch(descriptor)
        return dbEntries.map { $0.toDomain() }
    }

    public func deleteAllLocalUserData() async throws {
        logger.log("🧹 Starting full local data wipe...")
        
        // Efficient bulk deletion
        try modelContext.delete(model: SDUserProfile.self)
        try modelContext.delete(model: SDMindsetEntry.self)
        
        // Save the context to finalize the wipe
        try modelContext.save()
        
        logger.log("✅ All local user data deleted successfully.")
        
        // Notify any remaining UI components that the world has changed
        notificationCenter.post(name: .databaseDidChange, object: nil)
    }
}
