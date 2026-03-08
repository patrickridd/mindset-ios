//
//  MockPhoneVerificationProvider.swift
//  Domain
//
//  Created by Mindset Team on 3/8/26.
//

import Foundation

/// Mock implementation of PhoneVerificationProvider for testing and previews.
public final class MockPhoneVerificationProvider: PhoneVerificationProvider, Sendable {

    private let shouldSucceed: Bool

    public init(shouldSucceed: Bool = true) {
        self.shouldSucceed = shouldSucceed
    }

    public func requestVerificationCode(phoneNumber: String) async throws -> String {
        guard shouldSucceed else {
            throw NSError(
                domain: "MockPhoneVerificationProvider",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mock phone verification failed"]
            )
        }
        return "mock-verification-id"
    }
}
