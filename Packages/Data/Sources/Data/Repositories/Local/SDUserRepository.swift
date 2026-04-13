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

    public func fetchUser() async throws -> User? {
        let descriptor = FetchDescriptor<SDUser>()
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    public func saveUser(_ profile: User) async throws {
        let userId = profile.id
        let descriptor = FetchDescriptor<SDUser>(
            predicate: #Predicate<SDUser> { $0.id == userId }
        )
        
        // Check if the object already exists in the database
        if let existingUser = try modelContext.fetch(descriptor).first {
            logger.log("👤 Updating **Existing** `SDUser`")
            existingUser.update(from: profile)
        } else {
            let newUser = SDUser.fromDomain(profile)
            logger.log("👤 Creating **NEW** `SDUser`")
            
            modelContext.insert(newUser)
        }
        
        try modelContext.save()
    }

    public func deleteUser() async throws {
        try modelContext.delete(model: SDUser.self)
        try modelContext.save()
    }

    public func isOnboardingComplete() async -> Bool {
        (try? await fetchUser()?.isOnboardingComplete) ?? false
    }
}

extension SDUserRepository: LocalDataCleaner {
    public func purgeLocalCache() async throws {
        try await deleteUser()
    }
}
