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
import UIKit

/// Two-step phone sign-in flow: (1) enter phone, send code, (2) enter code, verify.
public struct PhoneSignInView: View {
    @Bindable var phoneViewModel: PhoneSignInViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sizeCategory) private var sizeCategory

    public init(phoneViewModel: PhoneSignInViewModel) {
        self.phoneViewModel = phoneViewModel
    }

    // MARK: - Body Composition

    public var body: some View {
        ZStack {
            BackgroundLinearGradientView()

            VStack(alignment: .leading, spacing: MindsetLayout.spacing20) {
                titleSection
                if phoneViewModel.step == .phoneNumber {
                    phoneNumberStep
                } else {
                    verificationCodeStep
                }
                errorSection
                subtitleSection
                    .padding(.horizontal, MindsetLayout.paddingMedium)

                Spacer()
            }
            .animation(.easeInOut, value: phoneViewModel.step)
            .padding(MindsetLayout.paddingScreenHorizontal)

            keyboardBarOverlay
        }
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(MindsetColors.backgroundDark.opacity(0.95), for: .navigationBar)
        .fullScreenCover(isPresented: $phoneViewModel.showCountryPicker) {
            CountryCodePickerSheet(
                selectedRegionCode: $phoneViewModel.selectedRegionCode,
                onSelect: {
                    HapticManager.selection()
                    phoneViewModel.showCountryPicker = false
                }
            )
        }
        .sheet(isPresented: $phoneViewModel.showResendOptionsSheet, onDismiss: {
            if phoneViewModel.shouldGoBackToPhoneNumberOnSheetDismiss {
                phoneViewModel.goBackToPhoneNumber()
                phoneViewModel.shouldGoBackToPhoneNumberOnSheetDismiss = false
            }
        }) {
            resendOptionsSheet
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

    var isKeyboardBarVisible: Bool {
        // Both steps use immediate-focus representables (keyboard visible when step is shown)
        true
    }

    var textFieldHeight: CGFloat {
        ImmediateFocusTextFieldRepresentable.textFieldHeight(for: sizeCategory)
    }

    var errorSection: some View {
        Group {
            if let error = phoneViewModel.signInViewModel.errorMessage {
                Text(error)
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.accentDestructiveRed)
                    .multilineTextAlignment(.center)
            }
            if let validationError = phoneViewModel.validationError {
                Text(validationError)
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.accentDestructiveRed)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var heroSection: some View {
        ZStack {
            Circle()
                .fill(MindsetColors.accentOrange.opacity(0.15))
                .frame(
                    width: MindsetLayout.heroCircleSize,
                    height: MindsetLayout.heroCircleSize
                )
                .blur(radius: MindsetLayout.glowBlurRadius)

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(MindsetColors.accentOrange)
        }
    }

    @ViewBuilder
    var titleSection: some View {
        HStack(alignment: .top, spacing: MindsetLayout.spacing8) {
            MindsetIconButton(icon: phoneViewModel.step.icon, color: .green, sizeRatio: 0.75)
            Text(phoneViewModel.step.title)
                .font(MindsetFonts.displayHeadline)
                .foregroundStyle(MindsetColors.textPrimaryDark)
        }
    }

    @ViewBuilder
    var subtitleSection: some View {
        Text(phoneViewModel.step.subtitle)
            .font(MindsetFonts.body)
            .multilineTextAlignment(.leading)
            .foregroundStyle(MindsetColors.textSecondaryDark)
    }

    var secondaryButton: some View {
        Button {
            HapticManager.selection()
            switch phoneViewModel.step {
            case .phoneNumber:
                phoneViewModel.onShowPrivacyPolicy?()
            case .verificationCode:
                phoneViewModel.showResendOptionsSheet = true
            }
        } label: {
            Text(phoneViewModel.step.secondaryButtonTitle)
                .font(MindsetFonts.body.weight(.medium))
                .foregroundStyle(.link)
        }
        .buttonStyle(.plain)
    }

    var resendOptionsSheet: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            Button {
                HapticManager.action()
                phoneViewModel.showResendOptionsSheet = false
                Task { await phoneViewModel.resendCode() }
            } label: {
                Text(FeatureAuthStrings.resendCode)
                    .font(MindsetFonts.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MindsetLayout.paddingStandard)
            }
            .buttonStyle(.borderedProminent)
            .tint(MindsetColors.accentOrange)

            Button {
                HapticManager.action()
                phoneViewModel.shouldGoBackToPhoneNumberOnSheetDismiss = true
                phoneViewModel.showResendOptionsSheet = false
            } label: {
                Text(FeatureAuthStrings.editNumber)
                    .font(MindsetFonts.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MindsetLayout.paddingStandard)
            }
            .buttonStyle(.bordered)
        }
        .padding(MindsetLayout.paddingScreenHorizontal)
        .presentationDetents(
            [.height(MindsetLayout.detentSmall)]
        )
    }

    var keyboardBarOverlay: some View {
        VStack {
            Spacer()
            if isKeyboardBarVisible {
                customKeyboardBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    var customKeyboardBar: some View {
        HStack(alignment: .center) {
            secondaryButton
                .padding([.horizontal, .bottom], MindsetLayout.paddingMedium)
            Spacer()
            if #available(iOS 26.0, *) {
                keyboardSubmitButton
                    .glassEffect(
                        .regular.interactive(),
                        in: .circle
                    )
            } else {
                // Fallback on earlier versions
                keyboardSubmitButton
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MindsetLayout.paddingLarge)
        .padding(.bottom, MindsetLayout.spacing8)
        .background(.clear)
        .animation(.easeInOut, value: phoneViewModel.step)
    }

    var keyboardSubmitButton: some View {
        Button {
            HapticManager.action()
            Task { await phoneViewModel.submit() }
        } label: {
            Image(systemName: "chevron.right")
                .font(MindsetFonts.body)
                .frame(
                    width: MindsetLayout.iconButtonLarge + 2,
                    height: MindsetLayout.iconButtonLarge + 2
                )
        }
        .foregroundStyle(
            phoneViewModel.canSubmit
                ? MindsetColors.accentOrange
                : MindsetColors.textDisabled(for: colorScheme)
        )
        .disabled(!phoneViewModel.canSubmit)
        .accessibilityLabel(phoneViewModel.submitButtonAccessibilityLabel)
    }

    var phoneNumberStep: some View {
        HStack(spacing: MindsetLayout.spacing8) {
            countryPickerButton
            phoneNumberField
        }
        .frame(
            minHeight: textFieldHeight,
            maxHeight: textFieldHeight,
            alignment: .center
        )
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
                    .foregroundStyle(MindsetColors.textPrimaryDark)
                Image(systemName: "chevron.down")
                    .font(.system(size: MindsetLayout.iconSmall, weight: .medium))
                    .foregroundStyle(MindsetColors.textSecondaryDark)
            }
            .padding(.horizontal, MindsetLayout.paddingMedium)
            .padding(.vertical, MindsetLayout.paddingSmall)
        }
        .buttonStyle(.plain)
    }

    var phoneNumberField: some View {
        PhoneNumberTextField(
            nationalNumber: $phoneViewModel.nationalNumber,
            regionCode: phoneViewModel.selectedRegionCode,
            placeholder: "",
            phoneNumberKit: phoneViewModel.phoneNumberKit,
            height: textFieldHeight,
            immediateFocus: true
        )
    }

    var verificationCodeStep: some View {
        ImmediateFocusTextFieldRepresentable(
            text: $phoneViewModel.verificationCode,
            placeholder: FeatureAuthStrings.codePlaceholder,
            keyboardType: .numberPad,
            textContentType: .oneTimeCode
        )
        .frame(
            minHeight: textFieldHeight,
            maxHeight: textFieldHeight,
            alignment: .center
        )
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
    }

    func flagEmoji(for regionCode: String) -> String {
        let base: UInt32 = 127397
        return regionCode.uppercased().unicodeScalars
            .compactMap { UnicodeScalar(base + $0.value) }
            .map { String($0) }
            .joined()
    }
}

#Preview("Phone Step") {
    let signInViewModel = SignInViewModel(
        signInOrLinkUseCase: SignInOrLinkUseCase(
            authService: MockAuthService(),
            userRepository: MockUserRepository(),
            logger: DebugLogger.shared
        ),
        appleSignInCredentialBuilder: AppleSignInCredentialBuilder(
            nonceStorage: AppleSignInNonceStorage()),
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

#Preview("Verify Step") {
    let signInViewModel = SignInViewModel(
        signInOrLinkUseCase: SignInOrLinkUseCase(
            authService: MockAuthService(),
            userRepository: MockUserRepository(),
            logger: DebugLogger.shared
        ),
        appleSignInCredentialBuilder: AppleSignInCredentialBuilder(
            nonceStorage: AppleSignInNonceStorage()),
        googleSignInCredentialProvider: MockGoogleSignInCredentialProvider(),
        phoneVerificationProvider: MockPhoneVerificationProvider(),
        logger: DebugLogger.shared,
        onPhoneSignInButtonTapped: {},
        onSignInSuccess: { _ in },
        onSkip: {}
    )
    let viewModel = PhoneSignInViewModel(signInViewModel: signInViewModel, step: .verificationCode)
    PhoneSignInView(phoneViewModel: viewModel)
}
