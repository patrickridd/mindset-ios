//
//  FirestoreUserRepository.swift
//  Data
//
//  Created by patrick ridd on 3/18/26.
//

import Domain
import FirebaseFirestore

@MainActor
public final class FirestoreUserRepository: UserRepository {

    private let db = Firestore.firestore()
    private let usersCollectionPath = "users"
    private let authStateQuery: AuthStateQuery
    private let logger: AppLogger

    public init(authStateQuery: AuthStateQuery, logger: AppLogger) {
        self.authStateQuery = authStateQuery
        self.logger = logger
    }

    public func fetchUserProfile() async throws -> UserProfile? {
        guard let uid = await authStateQuery.getCurrentUserID() else {
            logger.log("📵 User not logged in. Cannot fetch remote user profile. Returning nil.")
            return nil
        }

        let docRef = db.collection(usersCollectionPath).document(uid)
        
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

    public func saveUserProfile(_ profile: UserProfile) async throws {
        let dto = UserProfileDTO(from: profile)
        
        // Use setData with merge: true to avoid accidentally overwriting 
        // fields if you ever add server-side properties (like 'isPremium')
        try db.collection(usersCollectionPath)
            .document(profile.id)
            .setData(from: dto, merge: true)
    }

    public func deleteProfile() async throws {
        guard let uid = await authStateQuery.getCurrentUserID() else {
            logger.log("📵 User not logged in. Cannot delete remote user profile")
            return
        }

        try await db.collection(usersCollectionPath).document(uid).delete()
        logger.log("🗑️ Remote profile anchor purged for \(uid)")
    }

    public func isOnboardingComplete() async -> Bool {
        (try? await fetchUserProfile()?.isOnboardingComplete) ?? false
    }
}
