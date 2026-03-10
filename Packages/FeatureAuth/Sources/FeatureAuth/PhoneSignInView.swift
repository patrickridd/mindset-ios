//
//  PhoneSignInView.swift
//  FeatureAuth
//
//  Created by Mindset Team on 3/8/26.
//

import Domain
import PhoneNumberKit
import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

/// Two-step phone sign-in flow: (1) enter phone, send code, (2) enter code, verify.
public struct PhoneSignInView: View {
    @Bindable var viewModel: SignInViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var step: Step = .phoneNumber
    @State private var nationalNumber = ""
    @State private var verificationCode = ""
    @State private var verificationID: String?
    @State private var isSendingCode = false
    @State private var showCountryPicker = false
    @State private var validationError: String?
    @FocusState private var isPhoneFieldFocused
    @FocusState private var isCodeFieldFocused

    @State private var selectedRegionCode: String = {
        Locale.current.region?.identifier ?? "US"
    }()

    private let phoneNumberKit = PhoneNumberKit()

    private var selectedCountry: CountryInfo {
        CountryInfo.byRegionCode[selectedRegionCode] ?? CountryInfo.byRegionCode["US"]!
    }

    private enum Step {
        case phoneNumber
        case verificationCode
    }

    public init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body Composition

    public var body: some View {
        VStack(spacing: MindsetLayout.spacing20) {
            if step == .phoneNumber {
                phoneNumberStep
            } else {
                verificationCodeStep
            }
            errorSection
        }
        .padding(MindsetLayout.paddingScreenHorizontal)
        .navigationTitle(FeatureAuthStrings.phoneSignInTitle)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            isPhoneFieldFocused = true
        }
        .onAppear {
            isCodeFieldFocused = true
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryCodePickerSheet(
                selectedRegionCode: $selectedRegionCode,
                onSelect: {
                    HapticManager.selection()
                    showCountryPicker = false
                }
            )
        }
    }
}

// MARK: - Subviews

private extension PhoneSignInView {
    var errorSection: some View {
        Group {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(MindsetFonts.caption)
                    .foregroundStyle(MindsetColors.accentCoral)
                    .multilineTextAlignment(.center)
            }
            if let validationError {
                Text(validationError)
                    .font(MindsetFonts.caption)
                    .foregroundStyle(MindsetColors.accentCoral)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var phoneNumberStep: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            HStack(spacing: MindsetLayout.spacing8) {
                countryPickerButton
                phoneNumberField
            }
            .padding(MindsetLayout.paddingStandard)
            .mindsetCard()

            Button {
                HapticManager.action()
                Task { await sendNumber() }
            } label: {
                Text(FeatureAuthStrings.sendNumber)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .frame(height: MindsetLayout.buttonHeight)
            }
            .disabled(nationalNumber.isEmpty || isSendingCode)
            .mindsetButton()
        }
    }

    var countryPickerButton: some View {
        Button {
            HapticManager.selection()
            showCountryPicker = true
        } label: {
            HStack(spacing: MindsetLayout.spacing6) {
                Text(flagEmoji(for: selectedRegionCode))
                    .font(.system(size: MindsetLayout.iconLarge))
                Text("+\(selectedCountry.dialCode)")
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                Image(systemName: "chevron.down")
                    .font(.system(size: MindsetLayout.iconSmall, weight: .medium))
                    .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
            }
            .padding(.horizontal, MindsetLayout.paddingMedium)
            .padding(.vertical, MindsetLayout.paddingSmall)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusMedium)
                    .fill(MindsetColors.backgroundCard(for: colorScheme))
            )
        }
        .buttonStyle(.plain)
    }

    var phoneNumberField: some View {
        PhoneNumberTextField(
            nationalNumber: $nationalNumber,
            regionCode: selectedRegionCode,
            placeholder: ""
        )
        .focused($isPhoneFieldFocused)
    }

    var verificationCodeStep: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            TextField(FeatureAuthStrings.codePlaceholder, text: $verificationCode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isCodeFieldFocused)

            Button {
                HapticManager.action()
                Task { await verifyCode() }
            } label: {
                Text(FeatureAuthStrings.verify)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .frame(height: MindsetLayout.buttonHeight)
            }
            .disabled(verificationCode.isEmpty || viewModel.isLoading)
            .mindsetButton()
        }
    }

    func sendNumber() async {
        validationError = nil
        viewModel.dismissError()

        guard let e164 = toE164(regionCode: selectedRegionCode, nationalNumber: nationalNumber)
        else {
            validationError = FeatureAuthStrings.Error.invalidPhoneNumber
            return
        }

        isSendingCode = true
        defer { isSendingCode = false }

        if let id = await viewModel.requestPhoneVerificationCode(phoneNumber: e164) {
            verificationID = id
            withAnimation {
                step = .verificationCode
            }
        }
    }

    func verifyCode() async {
        guard let id = verificationID else { return }

        await viewModel.signInWithPhone(
            verificationID: id,
            verificationCode: verificationCode.trimmingCharacters(in: .whitespaces)
        )
    }

    func toE164(regionCode: String, nationalNumber: String) -> String? {
        let digits = nationalNumber.filter { $0.isNumber }
        guard !digits.isEmpty else { return nil }
        guard let number = try? phoneNumberKit.parse(digits, withRegion: regionCode) else {
            return nil
        }
        return phoneNumberKit.format(number, toType: .e164)
    }

    func flagEmoji(for regionCode: String) -> String {
        let base: UInt32 = 127397
        return regionCode.uppercased().unicodeScalars
            .compactMap { UnicodeScalar(base + $0.value) }
            .map { String($0) }
            .joined()
    }
}

// MARK: - PhoneNumberTextField

private struct PhoneNumberTextField: View {
    @Binding var nationalNumber: String
    let regionCode: String
    let placeholder: String

    private var formattedBinding: Binding<String> {
        let country = CountryInfo.byRegionCode[regionCode] ?? CountryInfo.byRegionCode["US"]!
        return Binding(
            get: {
                let digits = nationalNumber.filter { $0.isNumber }
                guard !digits.isEmpty else { return "" }
                let formatter = PartialFormatter(defaultRegion: regionCode)
                let full = "+\(country.dialCode)\(digits)"
                return formatter.formatPartial(full)
            },
            set: { newValue in
                let digits = newValue.filter { $0.isNumber }
                nationalNumber = digits
            }
        )
    }

    var body: some View {
        TextField(placeholder, text: formattedBinding)
            .textFieldStyle(.plain)
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .autocorrectionDisabled()
    }
}

// MARK: - CountryInfo

private struct CountryInfo: Identifiable {
    let id: String
    let regionCode: String
    let dialCode: String
    let name: String

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

// MARK: - CountryCodePickerSheet

private struct CountryCodePickerSheet: View {
    @Binding var selectedRegionCode: String
    let onSelect: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var sortedCountries: [CountryInfo] {
        CountryInfo.byRegionCode.values.sorted { $0.name < $1.name }
    }

    var body: some View {
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
                                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                            Text("+\(country.dialCode)")
                                .font(MindsetFonts.caption)
                                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                        }
                        Spacer()
                        if country.regionCode == selectedRegionCode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(MindsetColors.labelAccent(for: colorScheme))
                        }
                    }
                    .padding(.vertical, MindsetLayout.spacing4)
                }
            }
            .navigationTitle(FeatureAuthStrings.selectCountry)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        HapticManager.selection()
                        dismiss()
                    } label: {
                        Text(SharedLocalizedString.done)
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
