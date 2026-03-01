//
//  MockSubscriptionService.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/6/26.
//

import Domain

public final class MockSubscriptionService: SubscriptionService, @unchecked Sendable {
    public var isPremium: Bool

    public init(isPremium: Bool = true) {
        self.isPremium = isPremium
    }

    public func checkSubscriptionStatus() async -> Bool {
        // Simulate a network delay
        try? await Task.sleep(for: .seconds(0.5))
        return isPremium
    }

    public func restorePurchases() async throws -> Bool {
        return isPremium
    }

    public func purchasePro() async throws -> Bool {
        isPremium = true
        return isPremium
    }
}
