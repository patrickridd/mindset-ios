//
//  UserProfile.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

import Foundation

public struct UserProfile: Sendable {
    
    public let id: UUID
    public var userName: String
    public var primaryGoal: String
    public let createdAt: Date
    public let overwhelmedFrequency: OverwhelmedFrequency

    public init(
        id: UUID = UUID(),
        userName: String,
        primaryGoal: String,
        overwhelmedFrequency: OverwhelmedFrequency,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userName = userName
        self.primaryGoal = primaryGoal
        self.overwhelmedFrequency = overwhelmedFrequency
        self.createdAt = createdAt
    }
    
    public enum OverwhelmedFrequency: String, Codable, CaseIterable, Sendable {
        case rarely = "Rarely"
        case sometimes = "Sometimes"
        case often = "Often"
        case always = "Always"
    }
}
