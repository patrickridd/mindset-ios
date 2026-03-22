//
//  RemoteUserRepository.swift
//  Domain
//
//  Created by patrick ridd on 3/18/26.
//


/// A specialized repository for handling remote operations concerning our ``UserProfile``.
public protocol RemoteUserRepository: Sendable {
    /// Fetches the user profile from backend using the authenticated UID.
    func fetchRemoteProfile(uid: String) async throws -> UserProfile?
    
    /// Uploads the local profile to remote profile.
    func uploadProfile(_ profile: UserProfile) async throws

    /// Deletes Remote UserProfile that has the `uid`
    func deleteRemoteProfile(uid: String) async throws
}
