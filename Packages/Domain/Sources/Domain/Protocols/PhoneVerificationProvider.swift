//
//  PhoneVerificationProvider.swift
//  Domain
//
//  Created by Mindset Team on 3/8/26.
//

import Foundation

/// Protocol for sending SMS verification codes to phone numbers.
/// Enables DI and testing without coupling to Firebase.
public protocol PhoneVerificationProvider: Sendable {
    /// Sends SMS verification code to the phone number.
    /// - Parameter phoneNumber: E.164 format (e.g. +1234567890)
    /// - Returns: verificationID for use in AuthCredential.phone
    /// - Throws: When SMS fails, invalid number, or provider error
    func requestVerificationCode(phoneNumber: String) async throws -> String
}
