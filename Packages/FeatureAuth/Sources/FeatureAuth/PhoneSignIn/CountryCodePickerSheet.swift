//
//  CountryCodePickerSheet.swift
//  FeatureAuth
//
//  Created by patrick ridd on 3/9/26.
//

import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

struct CountryCodePickerSheet: View {
    @Binding var selectedRegionCode: String
    let onSelect: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var sortedCountries: [CountryInfo] {
        CountryInfo.byRegionCode.values.sorted { $0.name < $1.name }
    }

    private var backgroundView: some View {
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

    var body: some View {
        ZStack {
            backgroundView

            NavigationStack {
                List(sortedCountries) { country in
                    Button {
                        selectedRegionCode = country.regionCode
                        onSelect()
                        dismiss()
                    } label: {
                        HStack(spacing: MindsetLayout.spacing12) {
                            Text(flagEmoji(for: country.regionCode))
                                .font(.system(size: MindsetLayout.iconExtraLarge))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(country.name)
                                    .font(MindsetFonts.body)
                                    .foregroundStyle(MindsetColors.textPrimary)
                                Text("+\(country.dialCode)")
                                    .font(MindsetFonts.caption)
                                    .foregroundStyle(MindsetColors.textSecondary)
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
                .scrollContentBackground(.hidden)
                .navigationTitle(FeatureAuthStrings.selectCountry)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        HapticManager.selection()
                        dismiss()
                    } label: {
                        Text(SharedLocalizedString.done)
                            .foregroundStyle(MindsetColors.textPrimary)
                    }
                }
            }
            }
        }
    }

    private func flagEmoji(for regionCode: String) -> String {
        let base: UInt32 = 127397
        return regionCode.uppercased().unicodeScalars
            .compactMap { UnicodeScalar(base + $0.value) }
            .map { String($0) }
            .joined()
    }
}
