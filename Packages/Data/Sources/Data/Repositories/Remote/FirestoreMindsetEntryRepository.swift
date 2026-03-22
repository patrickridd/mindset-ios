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
public final class FirestoreMindsetEntryRepository: RemoteMindsetEntryRepository {
    private let db = Firestore.firestore()
    private let userSideCollection = "users"
    private let entrySubCollection = "entries"
    private let logger: AppLogger
    
    public init(logger: AppLogger) {
        self.logger = logger
    }

    private func entriesRef(for userId: String) -> CollectionReference {
        db.collection(userSideCollection)
            .document(userId)
            .collection(entrySubCollection)
    }

    public func fetchEntries(userId: String) async throws -> [MindsetEntry] {
        let snapshot = try await entriesRef(for: userId)
            .order(by: "dateCreated", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: MindsetEntryDTO.self).toDomain()
        }
    }

    public func uploadEntry(_ entry: MindsetEntry) async throws {
        let dto = MindsetEntryDTO(from: entry)
        
        try entriesRef(for: entry.userId)
            .document(dto.id) // Using the UUID string as doc ID
            .setData(from: dto, merge: true)
    }

    public func deleteRemoteEntries(for uid: String) async throws {
        let collectionRef = db.collection("users").document(uid).collection("entries")
        let snapshot = try await collectionRef.getDocuments()
        
        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
        logger.log("🗑️ Remote entries purged for \(uid)")
    }
}
