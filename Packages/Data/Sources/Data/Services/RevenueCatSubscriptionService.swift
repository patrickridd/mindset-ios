//
//  RevenueCatSubscriptionService.swift
//  Data
//
//  Created by patrick ridd on 1/7/26.
//

import Domain
// import Purchases // RevenueCat SDK

public final class RevenueCatSubscriptionService: SubscriptionService {

    public init() {
        // Purchases.configure(withAPIKey: "your_api_key")
    }

    public func checkSubscriptionStatus() async -> Bool {
        // Look up customer info in RevenueCat
        // let customerInfo = try? await Purchases.shared.customerInfo()
        // return customerInfo?.entitlements["pro"]?.isActive == true
        return false // Default
    }

    public func purchasePro() async throws -> Bool {
        // Trigger RevenueCat UI or custom purchase logic
        return true
    }

    // MARK: - SubscriptionService
    
    public func restorePurchases() async throws -> Bool {
        false
    }
}
