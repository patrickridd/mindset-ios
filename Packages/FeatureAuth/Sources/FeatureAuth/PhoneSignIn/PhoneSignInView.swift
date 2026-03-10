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
        ZStack {
            backgroundView

            VStack(spacing: MindsetLayout.spacing20) {
                if step == .phoneNumber {
                    phoneNumberStep
                } else {
                    verificationCodeStep
                }
                errorSection
            }
            .padding(MindsetLayout.paddingScreenHorizontal)
        }
        .navigationTitle(FeatureAuthStrings.phoneSignInTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(MindsetColors.backgroundDark.opacity(0.95), for: .navigationBar)
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
        .onChange(of: selectedRegionCode) { _, _ in
            let maxDigits = PhoneNumberValidation.maxNationalDigits(
                phoneNumberKit: phoneNumberKit,
                regionCode: selectedRegionCode
            )
            let digits = nationalNumber.filter { $0.isNumber }
            nationalNumber = String(digits.prefix(maxDigits))
        }
        .onChange(of: nationalNumber) { _, newValue in
            let maxDigits = PhoneNumberValidation.maxNationalDigits(
                phoneNumberKit: phoneNumberKit,
                regionCode: selectedRegionCode
            )
            let digits = newValue.filter { $0.isNumber }
            if digits.count > maxDigits {
                nationalNumber = String(digits.prefix(maxDigits))
            }
        }
    }
}

// MARK: - Subviews

private extension PhoneSignInView {
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

    var errorSection: some View {
        Group {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.accentCoral)
                    .multilineTextAlignment(.center)
            }
            if let validationError {
                Text(validationError)
                    .font(MindsetFonts.body)
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
                    .foregroundStyle(MindsetColors.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: MindsetLayout.iconSmall, weight: .medium))
                    .foregroundStyle(MindsetColors.textSecondary)
            }
            .padding(.horizontal, MindsetLayout.paddingMedium)
            .padding(.vertical, MindsetLayout.paddingSmall)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusMedium)
                    .fill(MindsetColors.fillSubtle)
            )
        }
        .buttonStyle(.plain)
    }

    var phoneNumberField: some View {
        PhoneNumberTextField(
            nationalNumber: $nationalNumber,
            regionCode: selectedRegionCode,
            placeholder: "",
            phoneNumberKit: phoneNumberKit
        )
        .focused($isPhoneFieldFocused)
    }

    var verificationCodeStep: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            TextField(FeatureAuthStrings.codePlaceholder, text: $verificationCode)
                .textFieldStyle(.plain)
                .font(MindsetFonts.body)
                .foregroundStyle(MindsetColors.textPrimary)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isCodeFieldFocused)
                .padding(MindsetLayout.paddingStandard)
                .background(
                    RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                        .fill(MindsetColors.fillSubtle)
                        .overlay(
                            RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                                .stroke(MindsetColors.borderSubtle, lineWidth: MindsetLayout.borderWidth)
                        )
                )

            Button {
                HapticManager.action()
                isCodeFieldFocused = false
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
