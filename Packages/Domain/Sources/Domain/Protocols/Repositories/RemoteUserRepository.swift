//
//  RemoteUserRepository.swift
//  Domain
//
//  Created by patrick ridd on 3/18/26.
//


/// A specialized repository for handling remote operations.
public protocol RemoteUserRepository: Sendable {
    /// Fetches the user profile from backend using the authenticated UID.
    func fetchRemoteProfile(uid: String) async throws -> UserProfile?
    
    /// Uploads the local profile to remote profile.
    func uploadProfile(_ profile: UserProfile) async throws
}
