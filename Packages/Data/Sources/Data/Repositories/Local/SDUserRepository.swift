//
//  SwiftDataUserRepository.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import Domain
import Foundation
import SwiftData

@MainActor
public final class SDUserRepository: UserRepository {

    private let modelContext: ModelContext
    private let logger: AppLogger
    private let notificationCenter: NotificationCenter

    public init(modelContext: ModelContext, logger: AppLogger, notificationCenter: NotificationCenter = .default) {
        self.modelContext = modelContext
        self.logger = logger
        self.notificationCenter = notificationCenter
    }

    public func fetchUserProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<SDUserProfile>()
        return try modelContext.fetch(descriptor).first?.toDomain()
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
    }

    public func deleteProfile() async throws {
        try modelContext.delete(model: SDUserProfile.self)
        try modelContext.save()
    }

    public func isOnboardingComplete() async -> Bool {
        (try? await fetchUserProfile()?.isOnboardingComplete) ?? false
    }
}

extension SDUserRepository: LocalDataCleaner {
    public func purgeLocalCache() async throws {
        try await deleteProfile()
    }
}
