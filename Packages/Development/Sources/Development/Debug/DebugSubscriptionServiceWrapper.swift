//
//  DebugSubscriptionServiceWrapper.swift
//  Development
//

import Domain

/// Decorator that intercepts `SubscriptionService` calls and applies the
/// `DebugSettings.isProOverrideEnabled` flag before delegating to the wrapped service.
/// Injected at the `ServiceFactory` level in `#if DEBUG` builds only.
public final class DebugSubscriptionServiceWrapper: SubscriptionService, @unchecked Sendable {
    private let wrapped: any SubscriptionService

    public init(wrapping service: any SubscriptionService) {
        self.wrapped = service
    }

    public func checkSubscriptionStatus() async -> Bool {
        let (overrideEnabled, overrideValue) = await MainActor.run {
            (DebugSettings.shared.isProOverrideEnabled, DebugSettings.shared.isProOverrideValue)
        }
        if overrideEnabled {
            return overrideValue
        }
        return await wrapped.checkSubscriptionStatus()
    }

    public func restorePurchases() async throws -> Bool {
        return try await wrapped.restorePurchases()
    }

    public func purchasePro() async throws -> Bool {
        return try await wrapped.purchasePro()
    }
}
