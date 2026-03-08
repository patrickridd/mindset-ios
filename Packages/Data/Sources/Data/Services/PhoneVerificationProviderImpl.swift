//
//  PhoneVerificationProviderImpl.swift
//  Data
//
//  Created by Mindset Team on 3/8/26.
//

import Domain
import FirebaseAuth
import Foundation
import SharedUtils

/// Firebase implementation of PhoneVerificationProvider using Firebase Phone Auth.
public final class PhoneVerificationProviderImpl: PhoneVerificationProvider, Sendable {

    private let logger: AppLogger

    public init(logger: AppLogger) {
        self.logger = logger
    }

    public func requestVerificationCode(phoneNumber: String) async throws -> String {
        #if canImport(UIKit)
        return try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(
                phoneNumber,
                uiDelegate: nil
            ) { [weak self] verificationID, error in
                if let error = error {
                    self?.logger.log("❌ Phone verification failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else if let verificationID = verificationID {
                    self?.logger.log("📱 Phone verification code sent")
                    continuation.resume(returning: verificationID)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "PhoneVerificationProviderImpl",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unknown error during phone verification"
                            ]
                        )
                    )
                }
            }
        }
        #else
        logger.log("⚠️ Phone verification is not supported on this platform")
        throw NSError(
            domain: "PhoneVerificationProviderImpl",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Phone verification is not supported on this platform"
            ]
        )
        #endif
    }
}
