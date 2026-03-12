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
        ZStack {
            backgroundView
            countryListView
        }
    }
}

// MARK: - Subviews

private extension CountryCodePickerSheet {
    var backgroundView: some View {
        LinearGradient(
            colors: [
                MindsetColors.backgroundDark,
                MindsetColors.backgroundDarkSoft,
                MindsetColors.backgroundWarmAccent.opacity(0.5),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var countryListView: some View {
        NavigationStack {
            List(sortedCountries) { country in
                countryRow(for: country)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(FeatureAuthStrings.selectCountry)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        HapticManager.selection()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
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
