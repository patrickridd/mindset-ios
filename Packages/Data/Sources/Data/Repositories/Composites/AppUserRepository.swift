//
//  AppUserRepository.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//

import Domain

public final class AppUserRepository: UserRepository {
    private let localStore: UserRepository
    private let remoteStore: RemoteUserRepository
    
    public init(local: UserRepository, remote: RemoteUserRepository) {
        self.localStore = local
        self.remoteStore = remote
    }

    public func fetchUserProfile() async throws -> UserProfile? {
        // 1. Always return local first for instant UI
        let localProfile = try await localStore.fetchUserProfile()
        
        // 2. Fire off a background sync if we have a network
        Task.detached { [weak self] in
            guard let self = self, let local = localProfile else { return }
            try? await self.remoteStore.uploadProfile(local)
        }
        
        return localProfile
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        // 1. Save locally so the Dashboard updates immediately
        try await localStore.saveUserProfile(profile)
        
        // 2. Push to Firestore
        try await remoteStore.uploadProfile(profile)
    }
    
    public func isOnboardingComplete() async -> Bool {
        await localStore.isOnboardingComplete()
    }
}
