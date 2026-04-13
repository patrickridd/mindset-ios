//
//  FirestoreUserStatsRepository.swift
//  Data
//
//  Created by patrick ridd on 4/9/26.
//


import Domain
import FirebaseFirestore

@MainActor
public final class FirestoreUserStatsRepository: UserStatsRepository {
    private let db = Firestore.firestore()
    private let collectionPath = "user_stats"
    private let logger: AppLogger

    public init(logger: AppLogger) {
        self.logger = logger
    }

    public func fetchStats(userId: String) async throws -> UserStats? {
        let docRef = db.collection(collectionPath).document(userId)
        let snapshot = try await docRef.getDocument()
        
        guard snapshot.exists else { return nil }
        
        // Assuming you create a UserStatsDTO similar to your UserDTO
        let dto = try snapshot.data(as: UserStatsDTO.self)
        return dto.toDomain()
    }

    public func updateStats(userId: String, xpDelta: Int, newStreak: Int) async throws {
        let docRef = db.collection(collectionPath).document(userId)
        
        // Atomic update: Increments XP and sets the new streak in one network call
        try await docRef.setData([
            "totalXP": FieldValue.increment(Int64(xpDelta)),
            "currentStreak": newStreak,
            "lastUpdated": FieldValue.serverTimestamp()
        ], merge: true)
        
        logger.log("☁️ Firestore: Stats updated for \(userId)")
    }

    public func incrementTotalXP(userId: String, by amount: Int) async throws {
        let docRef = db.collection(collectionPath).document(userId)
        try await docRef.updateData([
            "totalXP": FieldValue.increment(Int64(amount)),
            "lastUpdated": FieldValue.serverTimestamp()
        ])
    }
}

extension FirestoreUserStatsRepository: UserStatsSyncable {
    public func overwriteStats(userId: String, totalXP: Int, newStreak: Int, lastUpdated: Date) async throws {
        let docRef = db.collection(collectionPath).document(userId)
        
        // We use absolute values here, not increments
        try await docRef.setData([
            "totalXP": totalXP,
            "currentStreak": newStreak,
            "lastUpdated": Timestamp(date: lastUpdated)
        ], merge: true)
        
        logger.log("☁️ Firestore: Stats absolute overwrite completed.")
    }
}
