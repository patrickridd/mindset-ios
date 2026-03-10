//
//  PhoneNumberValidation.swift
//  FeatureAuth
//
//  Created by patrick ridd on 3/9/26.
//

import PhoneNumberKit

enum PhoneNumberValidation {
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
        let dialCode = (CountryInfo.byRegionCode[regionCode] ?? CountryInfo.byRegionCode["US"]!).dialCode
        return 15 - dialCode.count
    }
}
