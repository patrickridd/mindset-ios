//
//  PhoneNumberValidation.swift
//  FeatureAuth
//

import PhoneNumberKit

/// Validation and formatting utilities for phone number input.
enum PhoneNumberValidation {
    /// Returns digits-only string clamped to max national digits.
    static func clampToDigits(_ text: String, maxDigits: Int) -> String {
        let digits = text.filter { $0.isNumber }
        return String(digits.prefix(maxDigits))
    }

    /// Formats digits for display using region-specific PartialFormatter.
    static func formatForDisplay(
        _ digits: String,
        regionCode: String,
        maxDigits: Int,
        phoneNumberKit: PhoneNumberKit
    ) -> String {
        guard !digits.isEmpty else { return "" }
        let formatter = PartialFormatter(defaultRegion: regionCode, maxDigits: maxDigits)
        return formatter.formatPartial(digits)
    }

    /// Returns the maximum number of national digits for a given region.
    /// - Parameters:
    ///   - phoneNumberKit: PhoneNumberKit instance for region metadata.
    ///   - regionCode: ISO region code (e.g. "US").
    /// - Returns: Max national digits, or fallback when region is unknown.
    static func maxNationalDigits(phoneNumberKit: PhoneNumberKit, regionCode: String) -> Int {
        let mobileLengths = phoneNumberKit.possiblePhoneNumberLengths(
            forCountry: regionCode,
            phoneNumberType: .mobile,
            lengthType: .national
        )
        let fixedLengths = phoneNumberKit.possiblePhoneNumberLengths(
            forCountry: regionCode,
            phoneNumberType: .fixedLine,
            lengthType: .national
        )
        if let max = (mobileLengths + fixedLengths).max() {
            return max
        }
        guard
            let country = CountryInfo.byRegionCode[regionCode] ?? CountryInfo.byRegionCode["US"]
        else {
            return 10
        }
        return 15 - country.dialCode.count
    }
}
