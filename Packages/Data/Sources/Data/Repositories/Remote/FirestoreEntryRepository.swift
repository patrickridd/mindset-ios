//
//  FirestoreMindsetRepository.swift
//  Data
//
//  Created by patrick ridd on 3/19/26.
//

import Domain
import FirebaseFirestore
import FirebaseAuth
@MainActor
public final class FirestoreEntryRepository: EntryRepository {
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private let entrySubCollection = "entries"
    private let dateCreatedKey = "dateCreated"
    private let authStateQuery: AuthStateQuery
    private let logger: AppLogger
    
    public init(authStateQuery: AuthStateQuery, logger: AppLogger) {
        self.authStateQuery = authStateQuery
        self.logger = logger
    }

    private func entriesRef(for userId: String) -> CollectionReference {
        db.collection(usersCollection)
            .document(userId)
            .collection(entrySubCollection)
    }

    public func fetchAllEntries() async throws -> [Entry] {
        guard let userId = await authStateQuery.getCurrentUserID() else {
            logger.log("📵 No user is signed in. Returning empty entries.")
            return []
        }

        let snapshot = try await entriesRef(for: userId)
            .order(by: dateCreatedKey, descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: EntryDTO.self).toDomain()
        }
    }

    public func save(entry: Entry) async throws {
        let dto = EntryDTO(from: entry)
        
        try entriesRef(for: entry.userId)
            .document(dto.id) // Using the UUID string as doc ID
            .setData(from: dto, merge: true)
    }

    public func deleteRemoteEntries(for uid: String) async throws {
        let collectionRef = db.collection(usersCollection).document(uid).collection(entrySubCollection)
        let snapshot = try await collectionRef.getDocuments()
        
        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
        logger.log("🗑️ Remote entries purged for \(uid)")
    }

    public func fetchLatestEntry() async throws -> Domain.Entry? {
        (try? await fetchAllEntries().first) ?? nil
    }
    
    public func deleteAllEntries() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            logger.log("📵 No user signed in, can't delete remote entries.")
            return
        }
        
        let entriesRef = db.collection(usersCollection).document(uid).collection(entrySubCollection)
        
        // 3. Fetch all entries
        let snapshot = try await entriesRef.getDocuments()
        
        // 4. Batch delete (Atomically delete up to 500 docs)
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        
        try await batch.commit()
        logger.log("🗑️ Firestore: Sub-collection 'entries' purged for user \(uid)")
    }
}
