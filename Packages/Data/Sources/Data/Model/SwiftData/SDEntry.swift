//
//  SDEntry.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import Domain
import Foundation
import SwiftData

import Domain
import Foundation
import SwiftData

/// The persistent SwiftData storage model for a mindset entry.
///
/// This model acts as the database representation of a user's daily reflection or ritual.
/// It maintains a parent-child relationship with ``SDPromptResponse`` and includes
/// metadata for cloud synchronization and AI-driven analysis.
@Model
public final class SDEntry {
    /// A unique identifier for the entry, shared between local and remote databases.
    @Attribute(.unique) public var id: UUID
    
    /// The unique identifier of the user who owns this entry.
    /// Used for Firebase Security Rules and cross-device synchronization.
    public var userId: String
    
    /// The timestamp when the entry was created.
    public var dateCreated: Date
    
    /// A localized tag or identifier representing the AI-analyzed archetype for this day.
    public var archetypeTag: String?
    
    /// A numerical representation of the sentiment detected in the user's responses.
    public var sentimentScore: Double?

    /// Sum of XP Points earned for each PromptResponse in the `Entry` completed
    public var totalXpEarned: Int

    /// The collection of individual prompt-response pairs associated with this entry.
    ///
    /// This relationship uses a `.cascade` delete rule, ensuring that when an entry
    /// is deleted, all associated responses are also removed from the persistent store.
    @Relationship(deleteRule: .cascade)
    public var promptResponses: [SDPromptResponse] = []

    /// Initializes a new storage model for a mindset entry.
    /// - Parameters:
    ///   - id: The unique UUID for this entry.
    ///   - userId: The owner's unique identifier (from Firebase Auth).
    ///   - date: The creation date of the entry.
    ///   - archetypeTag: An optional archetype identifier.
    ///   - sentimentScore: An optional sentiment analysis score.
    ///   - totalXpEarned: Total XP Points earned for each PromptResponse in the Entry completed
    public init(
        id: UUID = UUID(),
        userId: String,
        dateCreated: Date = Date(),
        archetypeTag: String? = nil,
        sentimentScore: Double? = nil,
        totalXpEarned: Int
    ) {
        self.id = id
        self.userId = userId
        self.dateCreated = dateCreated
        self.archetypeTag = archetypeTag
        self.sentimentScore = sentimentScore
        self.totalXpEarned = totalXpEarned
    }
    
    /// Converts the persistent storage model into a clean Domain entity.
    /// - Returns: A thread-safe ``Entry`` struct.
    public func toDomain() -> Entry {
        Entry(
            id: id,
            userId: userId,
            dateCreated: dateCreated,
            promptResponses: promptResponses.map { $0.toDomain() },
            archetypeTag: archetypeTag,
            sentimentScore: sentimentScore,
            totalXpEarned: totalXpEarned
        )
    }

    /// Creates a new persistent storage model from a Domain entity.
    ///
    /// Use this method primarily for the initial insertion of an entry into the database.
    /// - Parameter domainEntry: The ``Entry`` struct to convert.
    /// - Returns: A new ``SDEntry`` instance ready for insertion.
    public static func fromDomain(_ domainEntry: Entry) -> SDEntry {
        let sdEntry = SDEntry(
            id: domainEntry.id,
            userId: domainEntry.userId,
            dateCreated: domainEntry.dateCreated,
            archetypeTag: domainEntry.archetypeTag,
            sentimentScore: domainEntry.sentimentScore,
            totalXpEarned: domainEntry.totalXpEarned
        )
        
        let sdResponses = domainEntry.promptResponses.map { response in
            let newResponse = SDPromptResponse(
                promptId: response.promptId,
                categoryValue: response.category.rawValue,
                answers: response.answers,
                aiReflection: response.aiReflection
            )
            newResponse.entry = sdEntry
            return newResponse
        }
        
        sdEntry.promptResponses = sdResponses
        return sdEntry
    }
}

extension SDEntry {
    /// Updates the existing persistent instance with new data from the Domain.
    ///
    /// This method performs a manual reconciliation of the `responses` relationship.
    /// It deletes existing child records from the context before inserting new ones
    /// to prevent "orphan" records in the persistent store.
    ///
    /// - Parameters:
    ///   - domain: The updated ``Entry`` data.
    ///   - context: The `ModelContext` used to manage the lifecycle of child responses.
    func update(from domain: Entry, in context: ModelContext) {
        self.userId = domain.userId
        self.dateCreated = domain.dateCreated
        self.archetypeTag = domain.archetypeTag
        self.sentimentScore = domain.sentimentScore
        self.totalXpEarned = domain.totalXpEarned
        // --- Reconcile Responses ---
        // We delete children to ensure a clean state, preventing database bloat.
        for response in self.promptResponses {
            context.delete(response)
        }
        
        let newSDResponses = domain.promptResponses.map { response in
            let newSD = SDPromptResponse(
                promptId: response.promptId,
                categoryValue: response.category.rawValue,
                answers: response.answers,
                aiReflection: response.aiReflection
            )
            newSD.entry = self
            return newSD
        }
        
        self.promptResponses = newSDResponses
    }
}
