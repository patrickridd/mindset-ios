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
        // Ensure we are saving to the CURRENT user's path,
        // regardless of what the entry object says (Security first)
        guard let userId = await authStateQuery.getCurrentUserID() else {
            logger.log("📵 Cannot save remote entry: No authenticated user.")
            return
        }

        let dto = EntryDTO(from: entry)
        
        try entriesRef(for: userId)
            .document(dto.id) // Using the UUID string as doc ID
            .setData(from: dto, merge: true)
    }

    public func fetchLatestEntry() async throws -> Domain.Entry? {
        guard let userId = await authStateQuery.getCurrentUserID() else { return nil }
        
        let snapshot = try await entriesRef(for: userId)
            .order(by: dateCreatedKey, descending: true)
            .limit(to: 1) // Only download 1 document
            .getDocuments()
        
        return try snapshot.documents.first?.data(as: EntryDTO.self).toDomain()
    }

    public func deleteAllEntries() async throws {
        guard let uid = await authStateQuery.getCurrentUserID() else { return }
        try await deleteRemoteEntries(for: uid)
    }
    
    private func deleteRemoteEntries(for uid: String) async throws {
        let ref = entriesRef(for: uid)
        
        // 1. Fetch all documents in the sub-collection
        // Note: iOS SDK downloads the full doc, but this is required for client-side batching
        let snapshot = try await ref.getDocuments()
        let documents = snapshot.documents
        
        guard !documents.isEmpty else {
            logger.log("ℹ️ No remote entries to delete.")
            return
        }

        logger.log("🗑️ Preparing to delete \(documents.count) entries in batches...")

        // 2. Chunk the documents into groups of 500 to stay under the limit
        let strideSize = 500
        for i in stride(from: 0, to: documents.count, by: strideSize) {
            let endIndex = min(i + strideSize, documents.count)
            let chunk = documents[i..<endIndex]
            
            let batch = db.batch()
            for doc in chunk {
                batch.deleteDocument(doc.reference)
            }
            
            // 3. Commit this specific batch
            try await batch.commit()
            logger.log("🧹 Batch complete: Deleted docs \(i + 1) through \(endIndex)")
        }
        
        logger.log("✅ All remote entries purged successfully.")
    }
}
