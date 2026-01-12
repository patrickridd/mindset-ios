//
//  MockSubscriptionService.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/6/26.
//

import Domain

public final class MockSubscriptionService: SubscriptionService, @unchecked Sendable {
    public var isPro: Bool
    
    public init(isPro: Bool = false) {
        self.isPro = isPro
    }
    
    public func checkSubscriptionStatus() async -> Bool {
        // Simulate a network delay
        try? await Task.sleep(for: .seconds(0.5))
        return isPro
    }
    
    public func restorePurchases() async throws -> Bool {
        return isPro
    }
    
    public func purchasePro() async throws -> Bool {
        isPro = true
        return isPro
    }
}
