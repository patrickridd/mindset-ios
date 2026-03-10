//
//  CountryInfo.swift
//  FeatureAuth
//

/// Country metadata for phone number input (region code, dial code, display name).
struct CountryInfo: Identifiable {
    let id: String
    let regionCode: String
    let dialCode: String
    let name: String

    /// Lookup by ISO region code (e.g. "US", "GB").
    static let byRegionCode: [String: CountryInfo] = {
        let pairs: [(String, String, String)] = [
            ("US", "1", "United States"),
            ("GB", "44", "United Kingdom"),
            ("CA", "1", "Canada"),
            ("AU", "61", "Australia"),
            ("DE", "49", "Germany"),
            ("FR", "33", "France"),
            ("ES", "34", "Spain"),
            ("IT", "39", "Italy"),
            ("NL", "31", "Netherlands"),
            ("BE", "32", "Belgium"),
            ("CH", "41", "Switzerland"),
            ("AT", "43", "Austria"),
            ("IE", "353", "Ireland"),
            ("NZ", "64", "New Zealand"),
            ("JP", "81", "Japan"),
            ("KR", "82", "South Korea"),
            ("CN", "86", "China"),
            ("IN", "91", "India"),
            ("BR", "55", "Brazil"),
            ("MX", "52", "Mexico"),
            ("AR", "54", "Argentina"),
            ("CO", "57", "Colombia"),
            ("CL", "56", "Chile"),
            ("PE", "51", "Peru"),
            ("ZA", "27", "South Africa"),
            ("NG", "234", "Nigeria"),
            ("KE", "254", "Kenya"),
            ("EG", "20", "Egypt"),
            ("PL", "48", "Poland"),
            ("SE", "46", "Sweden"),
            ("NO", "47", "Norway"),
            ("DK", "45", "Denmark"),
            ("FI", "358", "Finland"),
            ("PT", "351", "Portugal"),
            ("GR", "30", "Greece"),
            ("RU", "7", "Russia"),
            ("UA", "380", "Ukraine"),
            ("TR", "90", "Turkey"),
            ("IL", "972", "Israel"),
            ("SA", "966", "Saudi Arabia"),
            ("AE", "971", "United Arab Emirates"),
            ("SG", "65", "Singapore"),
            ("MY", "60", "Malaysia"),
            ("TH", "66", "Thailand"),
            ("PH", "63", "Philippines"),
            ("ID", "62", "Indonesia"),
            ("VN", "84", "Vietnam"),
            ("HK", "852", "Hong Kong"),
            ("TW", "886", "Taiwan"),
        ]
        return Dictionary(
            uniqueKeysWithValues: pairs.map { regionCode, dialCode, name in
                (
                    regionCode,
                    CountryInfo(
                        id: regionCode, regionCode: regionCode, dialCode: dialCode, name: name)
                )
            })
    }()
}
