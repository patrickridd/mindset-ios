//
//  FirestoreUserRepository.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//

import Domain
import FirebaseFirestore

@MainActor
public final class FirestoreUserRepository: RemoteUserRepository {
    private let db = Firestore.firestore()
    private let collectionPath = "users"

    public init() {}

    public func fetchRemoteProfile(uid: String) async throws -> UserProfile? {
        let snapshot = try await db.collection(collectionPath).document(uid).getDocument()
        
        // If the document doesn't exist, this is a new user (or local-only)
        guard snapshot.exists, let data = try? snapshot.data(as: UserProfileDTO.self) else {
            return nil
        }
        
        return data.toDomain()
    }

    public func uploadProfile(_ profile: UserProfile) async throws {
        let dto = UserProfileDTO(from: profile)
        
        // Use setData with merge: true to avoid accidentally overwriting 
        // fields if you ever add server-side properties (like 'isPremium')
        try db.collection(collectionPath)
            .document(profile.id)
            .setData(from: dto, merge: true)
    }
}
