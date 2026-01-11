//
//  SDUserProfile.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import SwiftData
import Domain
import Foundation

@Model
public final class SDUserProfile {
    @Attribute(.unique) public var id: UUID
    public var bestSelfName: String
    public var primaryGoal: String
    public var createdAt: Date
    // SwiftData stores Enums easily if they are String-backed
    public var overwhelmedFrequency: String

    public init(
        id: UUID = UUID(),
        bestSelfName: String,
        primaryGoal: String,
        overwhelmedFrequency: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.bestSelfName = bestSelfName
        self.primaryGoal = primaryGoal
        self.overwhelmedFrequency = overwhelmedFrequency
        self.createdAt = createdAt
    }

    // MARK: - Mapping
    
    /// Converts SwiftData storage model back to the clean Domain struct
    public func toDomain() -> UserProfile {
        return UserProfile(
            id: id,
            bestSelfName: bestSelfName,
            primaryGoal: primaryGoal,
            overwhelmedFrequency: UserProfile.OverwhelmedFrequency(rawValue: overwhelmedFrequency) ?? .sometimes,
            createdAt: createdAt
        )
    }
    
    /// Static helper to create a storage model from a Domain struct
    public static func fromDomain(_ domain: UserProfile) -> SDUserProfile {
        return SDUserProfile(
            id: domain.id,
            bestSelfName: domain.bestSelfName,
            primaryGoal: domain.primaryGoal,
            overwhelmedFrequency: domain.overwhelmedFrequency.rawValue,
            createdAt: domain.createdAt
        )
    }
}
