//
//  SubscriptionService 2.swift
//  Domain
//
//  Created by patrick ridd on 1/6/26.
//


// Domain/Sources/Domain/Protocols/SubscriptionService.swift

public protocol SubscriptionService: Sendable {
    /// Returns true if the user has an active premium subscription
    func checkSubscriptionStatus() async -> Bool
    
    /// Triggers the purchase flow
    func restorePurchases() async throws -> Bool
    
    /// Purchase Pro subcription
    func purchasePro() async throws -> Bool
}
