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
    
    public init() {}

    private func entriesRef(for userId: String) -> CollectionReference {
        db.collection(userSideCollection)
            .document(userId)
            .collection(entrySubCollection)
    }

    public func fetchEntries(userId: String) async throws -> [MindsetEntry] {
        print("🔍 Fetching for UID: \(userId) | Auth UID: \(Auth.auth().currentUser?.uid ?? "N/A")")

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
}
