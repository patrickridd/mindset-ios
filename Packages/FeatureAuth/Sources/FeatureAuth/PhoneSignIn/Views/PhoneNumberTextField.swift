//
//  PhoneNumberTextField.swift
//  FeatureAuth
//
//  Created by patrick ridd on 3/9/26.
//

import PhoneNumberKit
import SharedUI
import SwiftUI
import UIKit

private let authTextFieldHeight: CGFloat = 44

/// A text field for entering a national phone number with region-specific formatting.
///
/// Formats digits as-you-type using `PhoneNumberKit`'s `PartialFormatter` and keeps the bound
/// `nationalNumber` in sync with digits-only values. Used in the phone sign-in flow.
///
/// - Parameters:
///   - nationalNumber: Binding to the digits-only national number (no country code).
///   - regionCode: ISO region code (e.g. `"US"`) for formatting and digit limits.
///   - placeholder: Placeholder text when the field is empty.
///   - phoneNumberKit: `PhoneNumberKit` instance for validation and formatting.
///   - immediateFocus: When true, uses a UIKit-backed field that becomes first responder immediately
///     without keyboard animation. When false, uses SwiftUI TextField with onAppear focus.
struct PhoneNumberTextField: View {
    @Binding var nationalNumber: String

    let regionCode: String
    let placeholder: String
    let phoneNumberKit: PhoneNumberKit
    var immediateFocus: Bool = true

    private var maxDigits: Int {
        PhoneNumberValidation.maxNationalDigits(
            phoneNumberKit: phoneNumberKit, regionCode: regionCode)
    }

    @State private var editingText: String = ""

    // MARK: - Body Composition

    var body: some View {
        if immediateFocus {
            PhoneNumberTextFieldRepresentable(
                nationalNumber: $nationalNumber,
                regionCode: regionCode,
                placeholder: placeholder,
                phoneNumberKit: phoneNumberKit,
                maxDigits: maxDigits
            )
            .frame(
                minHeight: authTextFieldHeight,
                maxHeight: authTextFieldHeight,
                alignment: .center
            )
        } else {
            swiftUITextField
        }
    }

    private var swiftUITextField: some View {
        TextField(placeholder, text: $editingText)
            .textFieldStyle(.plain)
            .font(MindsetFonts.body)
            .foregroundStyle(MindsetColors.textPrimary)
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .autocorrectionDisabled()
            .onAppear {
                syncFromNationalNumber()
            }
            .onChange(of: editingText) { _, new in
                handleEditingTextChange(new)
            }
            .onChange(of: nationalNumber) { _, newValue in
                syncFromNationalNumber()
            }
            .frame(
                minHeight: authTextFieldHeight,
                maxHeight: authTextFieldHeight,
                alignment: .center
            )
    }
}

// MARK: - PhoneNumberTextFieldRepresentable

private struct PhoneNumberTextFieldRepresentable: UIViewRepresentable {
    @Binding var nationalNumber: String

    let regionCode: String
    let placeholder: String
    let phoneNumberKit: PhoneNumberKit
    let maxDigits: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(
            nationalNumber: $nationalNumber,
            regionCode: regionCode,
            maxDigits: maxDigits,
            phoneNumberKit: phoneNumberKit
        )
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.keyboardType = .phonePad
        textField.textContentType = .telephoneNumber
        textField.autocorrectionType = .no
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.textColor = UIColor(MindsetColors.textPrimary)
        textField.backgroundColor = .clear

        let formatted = PhoneNumberValidation.formatForDisplay(
            nationalNumber,
            regionCode: regionCode,
            maxDigits: maxDigits,
            phoneNumberKit: phoneNumberKit
        )
        textField.text = formatted

        UIView.performWithoutAnimation {
            textField.becomeFirstResponder()
        }

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        let formatted = PhoneNumberValidation.formatForDisplay(
            nationalNumber,
            regionCode: regionCode,
            maxDigits: maxDigits,
            phoneNumberKit: phoneNumberKit
        )
        if uiView.text != formatted {
            uiView.text = formatted
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var nationalNumber: String

        let regionCode: String
        let maxDigits: Int
        let phoneNumberKit: PhoneNumberKit

        init(
            nationalNumber: Binding<String>,
            regionCode: String,
            maxDigits: Int,
            phoneNumberKit: PhoneNumberKit
        ) {
            _nationalNumber = nationalNumber
            self.regionCode = regionCode
            self.maxDigits = maxDigits
            self.phoneNumberKit = phoneNumberKit
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let current = textField.text ?? ""
            let candidate = (current as NSString).replacingCharacters(in: range, with: string)
            let clamped = PhoneNumberValidation.clampToDigits(candidate, maxDigits: maxDigits)
            let formatted = PhoneNumberValidation.formatForDisplay(
                clamped,
                regionCode: regionCode,
                maxDigits: maxDigits,
                phoneNumberKit: phoneNumberKit
            )
            nationalNumber = clamped
            textField.text = formatted
            return false
        }
    }
}

// MARK: - Private Helpers (SwiftUI path)

private extension PhoneNumberTextField {
    /// Syncs `editingText` from the bound `nationalNumber` (used on appear and when nationalNumber changes externally).
    func syncFromNationalNumber() {
        let clamped = PhoneNumberValidation.clampToDigits(nationalNumber, maxDigits: maxDigits)
        if clamped != nationalNumber {
            nationalNumber = clamped
        }
        let formatted = PhoneNumberValidation.formatForDisplay(
            clamped,
            regionCode: regionCode,
            maxDigits: maxDigits,
            phoneNumberKit: phoneNumberKit
        )
        if formatted != editingText {
            editingText = formatted
        }
    }

    /// Handles user edits: updates bound value and reformats display.
    func handleEditingTextChange(_ new: String) {
        let clamped = PhoneNumberValidation.clampToDigits(new, maxDigits: maxDigits)
        if clamped != nationalNumber {
            nationalNumber = clamped
        }
        let formatted = PhoneNumberValidation.formatForDisplay(
            clamped,
            regionCode: regionCode,
            maxDigits: maxDigits,
            phoneNumberKit: phoneNumberKit
        )
        if formatted != new {
            editingText = formatted
        }
    }
}
