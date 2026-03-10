//
//  PhoneNumberValidation.swift
//  FeatureAuth
//

import PhoneNumberKit

/// Validation utilities for phone number input.
enum PhoneNumberValidation {
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
