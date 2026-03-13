//
//  CountryCodePickerSheet.swift
//  FeatureAuth
//

import SharedUI
import SharedUtils
import SwiftUI

/// Sheet for selecting a country/region code for phone number input.
struct CountryCodePickerSheet: View {
    @Binding var selectedRegionCode: String
    let onSelect: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var sortedCountries: [CountryInfo] {
        CountryInfo.byRegionCode.values.sorted { $0.name < $1.name }
    }

    // MARK: - Body Composition

    var body: some View {
        countryListView
    }
}

// MARK: - Subviews

private extension CountryCodePickerSheet {

    var countryListView: some View {
        NavigationStack {
            ZStack {
                MindsetColors.backgroundDarkSoft
                    .ignoresSafeArea()
                
                List(sortedCountries) { country in
                    countryRow(for: country)
                        .listRowBackground(Color.clear)
                }
                // 2. Hide the default list background
                .scrollContentBackground(.hidden)
                .navigationTitle(FeatureAuthStrings.selectCountry)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    SystemDismissButton()
                }

            }
        }
    }


    func countryRow(for country: CountryInfo) -> some View {
        Button {
            selectedRegionCode = country.regionCode
            onSelect()
            dismiss()
        } label: {
            HStack(spacing: MindsetLayout.spacing12) {
                Text(flagEmoji(for: country.regionCode))
                    .font(.system(size: MindsetLayout.iconExtraLarge))
                VStack(alignment: .leading, spacing: MindsetLayout.spacing4) {
                    Text(country.name)
                        .font(MindsetFonts.body)
                        .foregroundStyle(MindsetColors.textPrimaryDark)
                    Text("+\(country.dialCode)")
                        .font(MindsetFonts.caption)
                        .foregroundStyle(MindsetColors.textSecondaryDark)
                }
                Spacer()
                if country.regionCode == selectedRegionCode {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(MindsetColors.accentOrange)
                }
            }
            .padding(.vertical, MindsetLayout.spacing4)
        }
    }

    func flagEmoji(for regionCode: String) -> String {
        let base: UInt32 = 127397
        return regionCode.uppercased().unicodeScalars
            .compactMap { UnicodeScalar(base + $0.value) }
            .map { String($0) }
            .joined()
    }
}

#Preview {
    CountryCodePickerSheet(selectedRegionCode: .constant("US")) {
    }
}
