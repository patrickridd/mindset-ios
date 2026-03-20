//
//  FirestoreMindsetRepository.swift
//  Data
//
//  Created by patrick ridd on 3/19/26.
//

import Domain
import FirebaseFirestore

@MainActor
public final class FirestoreMindsetEntryRepository: RemoteMindsetEntryRepository {
    private let db = Firestore.firestore()
    
    public init() {}

    private func entriesCollection(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("entries")
    }

    public func uploadEntry(_ entry: MindsetEntry) async throws {
        let dto = MindsetEntryDTO(from: entry)
        try entriesCollection(for: entry.userId)
            .document(dto.id)
            .setData(from: dto, merge: true)
    }

    public func fetchEntries(userId: String) async throws -> [Domain.MindsetEntry] {
        let snapshot = try await entriesCollection(for: userId)
            .order(by: "dateCreated", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: MindsetEntryDTO.self).toDomain()
        }
    }
}
