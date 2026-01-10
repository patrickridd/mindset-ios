//
//  UserProfile.swift
//  Domain
//
//  Created by patrick ridd on 1/9/26.
//

import Foundation

public struct UserProfile: Sendable {
    public let id: String
    public var bestSelfName: String
    public var primaryGoal: String
    
    public init(id: String = "current", bestSelfName: String, primaryGoal: String, createdAt: Date = Date()) {
        self.id = id
        self.bestSelfName = bestSelfName
        self.primaryGoal = primaryGoal
    }
}
