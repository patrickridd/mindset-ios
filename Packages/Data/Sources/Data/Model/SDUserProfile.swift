//
//  SDUserProfile.swift
//  Data
//
//  Created by patrick ridd on 1/9/26.
//

import SwiftData
import Domain

@Model
public final class SDUserProfile {
    @Attribute(.unique) public var id: String
    public var bestSelfName: String
    public var primaryGoal: String

    public init(from domain: UserProfile) {
        self.id = domain.id
        self.bestSelfName = domain.bestSelfName
        self.primaryGoal = domain.primaryGoal
    }

    // Convert back to Domain for the UI to use
    public func toDomain() -> UserProfile {
        UserProfile(id: id, bestSelfName: bestSelfName, primaryGoal: primaryGoal)
    }
}
