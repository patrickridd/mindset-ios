//
//  PaywallViewModel.swift
//  FeatureSubscription
//
//  Created by patrick ridd on 1/11/26.
//

import Foundation
import Domain
import Observation

@Observable
@MainActor
public final class PaywallViewModel {
    private let subscriptionService: SubscriptionService
    public var isLoading = false
    public var errorMessage: String?
    
    public var onPurchaseFinished: (() -> Void)?

    public init(subscriptionService: SubscriptionService, onPurchaseFinished: (() -> Void)?) {
        self.subscriptionService = subscriptionService
        self.onPurchaseFinished = onPurchaseFinished
    }

    public func purchase() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let success = try await subscriptionService.purchasePro()
            if success {
                onPurchaseFinished?()
            } else {
                errorMessage = "Purchase could not be completed."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func closeButtonTapped() {
        onPurchaseFinished?()
    }
}
