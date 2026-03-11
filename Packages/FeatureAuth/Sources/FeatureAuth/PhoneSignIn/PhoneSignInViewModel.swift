//
//  PhoneSignInViewModel.swift
//  FeatureAuth
//
//  Created by Mindset Team on 3/10/26.
//

import Domain
import Foundation
import Observation
import PhoneNumberKit

@Observable
@MainActor
public final class PhoneSignInViewModel {
    public let signInViewModel: SignInViewModel

    public var step: Step = .phoneNumber
    public var nationalNumber = ""
    public var verificationCode = ""
    public var verificationID: String?
    public var isSendingCode = false
    public var showCountryPicker = false
    public var validationError: String?
    public var selectedRegionCode: String = Locale.current.region?.identifier ?? "US"

    let phoneNumberKit = PhoneNumberKit()

    var selectedCountry: CountryInfo {
        CountryInfo.byRegionCode[selectedRegionCode] ?? CountryInfo.byRegionCode["US"]!
    }

    public enum Step {
        case phoneNumber
        case verificationCode

        var icon: String {
            switch self {
            case .phoneNumber:
                return "phone"
            case .verificationCode:
                return "shield"
            }
        }

        var title: String {
            switch self {
            case .phoneNumber:
                return FeatureAuthStrings.phoneSignInTitle
            case .verificationCode:
                return FeatureAuthStrings.phoneVerifyTitle
            }
        }

        var subtitle: String {
            switch self {
            case .phoneNumber:
                return FeatureAuthStrings.phoneSignInSubtitle
            case .verificationCode:
                return FeatureAuthStrings.phoneVerifySubtitle
            }
        }
    }

    public init(signInViewModel: SignInViewModel) {
        self.signInViewModel = signInViewModel
    }

    // MARK: - Actions

    public func sendNumber() async {
        validationError = nil
        signInViewModel.dismissError()

        guard let e164 = toE164(regionCode: selectedRegionCode, nationalNumber: nationalNumber)
        else {
            validationError = FeatureAuthStrings.Error.invalidPhoneNumber
            return
        }

        isSendingCode = true
        defer { isSendingCode = false }

        if let id = await signInViewModel.requestPhoneVerificationCode(phoneNumber: e164) {
            verificationID = id
            step = .verificationCode
        }
    }

    public func verifyCode() async {
        guard let id = verificationID else { return }

        await signInViewModel.signInWithPhone(
            verificationID: id,
            verificationCode: verificationCode.trimmingCharacters(in: .whitespaces)
        )
    }

    /// Single entry point for keyboard toolbar submit. Dispatches to sendNumber or verifyCode based on step.
    public func submit() async {
        switch step {
        case .phoneNumber:
            await sendNumber()
        case .verificationCode:
            await verifyCode()
        }
    }

    // MARK: - Submit

    /// Whether the keyboard toolbar submit button should be enabled.
    public var canSubmit: Bool {
        switch step {
        case .phoneNumber:
            return !nationalNumber.isEmpty && !isSendingCode
        case .verificationCode:
            return !verificationCode.isEmpty && !signInViewModel.isLoading
        }
    }

    /// Localized accessibility label for the submit button (no UI types in ViewModel).
    public var submitButtonAccessibilityLabel: String {
        switch step {
        case .phoneNumber:
            return FeatureAuthStrings.sendNumber
        case .verificationCode:
            return FeatureAuthStrings.verify
        }
    }

    // MARK: - Validation

    public func toE164(regionCode: String, nationalNumber: String) -> String? {
        let digits = nationalNumber.filter { $0.isNumber }
        guard !digits.isEmpty else { return nil }
        guard let number = try? phoneNumberKit.parse(digits, withRegion: regionCode) else {
            return nil
        }
        return phoneNumberKit.format(number, toType: .e164)
    }

    /// Returns digits-only string truncated to max national digits for current region.
    public func validatedNationalNumber(_ value: String) -> String {
        let maxDigits = PhoneNumberValidation.maxNationalDigits(
            phoneNumberKit: phoneNumberKit,
            regionCode: selectedRegionCode
        )
        let digits = value.filter { $0.isNumber }
        return String(digits.prefix(maxDigits))
    }

    /// Truncates nationalNumber to max digits for current region. Call when selectedRegionCode changes.
    public func truncateNationalNumberToCurrentRegion() {
        nationalNumber = validatedNationalNumber(nationalNumber)
    }
}
