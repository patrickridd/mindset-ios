//
//  PhoneSignInView.swift
//  FeatureAuth
//
//  Created by Mindset Team on 3/8/26.
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

/// Two-step phone sign-in flow: (1) enter phone, send code, (2) enter code, verify.
public struct PhoneSignInView: View {
    @Bindable var viewModel: SignInViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var step: Step = .phoneNumber
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var verificationID: String?
    @State private var isSendingCode = false

    private enum Step {
        case phoneNumber
        case verificationCode
    }

    public init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: MindsetLayout.spacing20) {
                if step == .phoneNumber {
                    phoneNumberStep
                } else {
                    verificationCodeStep
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(MindsetFonts.caption)
                        .foregroundStyle(MindsetColors.accentCoral)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(MindsetLayout.paddingScreenHorizontal)
            .navigationTitle(FeatureAuthStrings.phoneSignInTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.selection()
                        dismiss()
                    }
                }
            }
        }
    }

    private var phoneNumberStep: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            TextField(FeatureAuthStrings.phonePlaceholder, text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .autocorrectionDisabled()

            Button {
                HapticManager.action()
                Task { await sendCode() }
            } label: {
                Text(FeatureAuthStrings.sendCode)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .frame(height: MindsetLayout.buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                            .fill(MindsetColors.accentOrange)
                    )
            }
            .disabled(phoneNumber.isEmpty || isSendingCode)
        }
    }

    private var verificationCodeStep: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            TextField(FeatureAuthStrings.codePlaceholder, text: $verificationCode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)

            Button {
                HapticManager.action()
                Task { await verifyCode() }
            } label: {
                Text(FeatureAuthStrings.verify)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .frame(height: MindsetLayout.buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                            .fill(MindsetColors.accentOrange)
                    )
            }
            .disabled(verificationCode.isEmpty || viewModel.isLoading)
        }
    }

    private func sendCode() async {
        let normalized = normalizePhoneNumber(phoneNumber)
        guard !normalized.isEmpty else { return }

        isSendingCode = true
        defer { isSendingCode = false }

        if let id = await viewModel.requestPhoneVerificationCode(phoneNumber: normalized) {
            verificationID = id
            step = .verificationCode
        }
    }

    private func verifyCode() async {
        guard let id = verificationID else { return }

        await viewModel.signInWithPhone(
            verificationID: id,
            verificationCode: verificationCode.trimmingCharacters(in: .whitespaces)
        )
    }

    private func normalizePhoneNumber(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        guard !digits.isEmpty else { return "" }
        if digits.hasPrefix("1") && digits.count == 11 {
            return "+" + digits
        }
        if digits.count == 10 {
            return "+1" + digits
        }
        return "+" + digits
    }
}
