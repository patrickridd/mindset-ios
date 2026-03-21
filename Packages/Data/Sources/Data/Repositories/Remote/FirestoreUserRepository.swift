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
    private let logger: AppLogger
    public init(logger: AppLogger) {
        self.logger = logger
    }

    public func fetchRemoteProfile(uid: String) async throws -> UserProfile? {

        let docRef = db.collection(collectionPath).document(uid)
        
        do {
            let snapshot = try await docRef.getDocument()
            
            // 1. Check if the document actually exists in Firestore
            guard snapshot.exists else {
                logger.log("☁️ Firestore: Document does not exist for UID: \(uid). Returning nil.")
                return nil
            }
            
            // 2. Try to decode the data
            let dto = try snapshot.data(as: UserProfileDTO.self)
            return dto.toDomain()
            
        } catch {
            // 3. Handle the 'Permission Denied' or 'API Disabled' error gracefully
            // We log it for debugging, but return nil so the AppUserRepository
            // knows it needs to perform an upload.
            logger.log("⚠️ Firestore Fetch suppressed error: \(error.localizedDescription)")
            return nil
        }
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
