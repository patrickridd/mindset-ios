//
//  PhoneSignInView.swift
//  FeatureAuth
//
//  Created by Mindset Team on 3/8/26.
//

import Domain
import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

/// Two-step phone sign-in flow: (1) enter phone, send code, (2) enter code, verify.
public struct PhoneSignInView: View {
    @Bindable var phoneViewModel: PhoneSignInViewModel
    @Environment(\.colorScheme) private var colorScheme

    @FocusState private var isPhoneFieldFocused
    @FocusState private var isCodeFieldFocused

    public init(phoneViewModel: PhoneSignInViewModel) {
        self.phoneViewModel = phoneViewModel
    }

    // MARK: - Body Composition

    public var body: some View {
        ZStack {
            backgroundView
            VStack(alignment: .leading, spacing: MindsetLayout.spacing20) {
                titleSection
                if phoneViewModel.step == .phoneNumber {
                    phoneNumberStep
                } else {
                    verificationCodeStep
                }
                subtitleSection
                Spacer()
                errorSection
            }
            .animation(.default, value: phoneViewModel.step)
            .padding(MindsetLayout.paddingScreenHorizontal)
            .padding(.top, 40)
        }
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(MindsetColors.backgroundDark.opacity(0.95), for: .navigationBar)
        .onAppear {
            isPhoneFieldFocused = true
        }
        .onAppear {
            isCodeFieldFocused = true
        }
        .sheet(isPresented: $phoneViewModel.showCountryPicker) {
            CountryCodePickerSheet(
                selectedRegionCode: $phoneViewModel.selectedRegionCode,
                onSelect: {
                    HapticManager.selection()
                    phoneViewModel.showCountryPicker = false
                }
            )
        }
        .onChange(of: phoneViewModel.selectedRegionCode) { _, _ in
            phoneViewModel.truncateNationalNumberToCurrentRegion()
        }
        .onChange(of: phoneViewModel.nationalNumber) { _, newValue in
            let validated = phoneViewModel.validatedNationalNumber(newValue)
            if validated != newValue {
                phoneViewModel.nationalNumber = validated
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
            if let error = phoneViewModel.signInViewModel.errorMessage {
                Text(error)
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.accentCoral)
                    .multilineTextAlignment(.center)
            }
            if let validationError = phoneViewModel.validationError {
                Text(validationError)
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.accentCoral)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder
    var titleSection: some View {
        HStack(spacing: MindsetLayout.spacing8) {
            MindsetIconButton(icon: phoneViewModel.step.icon, color: .green, sizeRatio: 0.5)
            Text(phoneViewModel.step.title)
                .font(MindsetFonts.buttonSignIn)
                .foregroundStyle(MindsetColors.textPrimary)
        }
    }

    @ViewBuilder
    var subtitleSection: some View {
        Text(phoneViewModel.step.subtitle)
            .font(MindsetFonts.body)
            .multilineTextAlignment(.leading)
            .foregroundStyle(MindsetColors.textSecondary)
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
                Task { await phoneViewModel.sendNumber() }
            } label: {
                Text(FeatureAuthStrings.sendNumber)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .frame(height: MindsetLayout.buttonHeight)
            }
            .disabled(phoneViewModel.nationalNumber.isEmpty || phoneViewModel.isSendingCode)
            .mindsetButton()
        }
    }

    var countryPickerButton: some View {
        Button {
            HapticManager.selection()
            phoneViewModel.showCountryPicker = true
        } label: {
            HStack(spacing: MindsetLayout.spacing6) {
                Text(flagEmoji(for: phoneViewModel.selectedRegionCode))
                    .font(.system(size: MindsetLayout.iconLarge))
                Text("+\(phoneViewModel.selectedCountry.dialCode)")
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
            nationalNumber: $phoneViewModel.nationalNumber,
            regionCode: phoneViewModel.selectedRegionCode,
            placeholder: "",
            phoneNumberKit: phoneViewModel.phoneNumberKit
        )
        .focused($isPhoneFieldFocused)
    }

    var verificationCodeStep: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            TextField(FeatureAuthStrings.codePlaceholder, text: $phoneViewModel.verificationCode)
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
                                .stroke(
                                    MindsetColors.borderSubtle, lineWidth: MindsetLayout.borderWidth
                                )
                        )
                )

            Button {
                HapticManager.action()
                isCodeFieldFocused = false
                Task { await phoneViewModel.verifyCode() }
            } label: {
                Text(FeatureAuthStrings.verify)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .frame(height: MindsetLayout.buttonHeight)
            }
            .disabled(
                phoneViewModel.verificationCode.isEmpty || phoneViewModel.signInViewModel.isLoading
            )
            .mindsetButton()
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
    let signInViewModel = SignInViewModel(
        signInOrLinkUseCase: SignInOrLinkUseCase(authService: MockAuthService()),
        appleSignInCredentialBuilder: AppleSignInCredentialBuilder(nonceStorage: AppleSignInNonceStorage()),
        googleSignInCredentialProvider: MockGoogleSignInCredentialProvider(),
        phoneVerificationProvider: MockPhoneVerificationProvider(),
        logger: DebugLogger.shared,
        onPhoneSignInButtonTapped: {},
        onSignInSuccess: { _ in },
        onSkip: {}
    )
    let viewModel = PhoneSignInViewModel(signInViewModel: signInViewModel)
    
    PhoneSignInView(phoneViewModel: viewModel)
}
