//
//  PhoneNumberTextField.swift
//  FeatureAuth
//
//  Created by patrick ridd on 3/9/26.
//

import PhoneNumberKit
import SharedUI
import SwiftUI

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
struct PhoneNumberTextField: View {
    @Binding var nationalNumber: String

    let regionCode: String
    let placeholder: String
    let phoneNumberKit: PhoneNumberKit

    private var maxDigits: Int {
        PhoneNumberValidation.maxNationalDigits(
            phoneNumberKit: phoneNumberKit, regionCode: regionCode)
    }

    @State private var editingText: String = ""

    // MARK: - Body Composition

    var body: some View {
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
    }
}

// MARK: - Private Helpers

private extension PhoneNumberTextField {
    /// Returns digits-only string clamped to max national digits for the region.
    func clampToDigits(_ text: String) -> String {
        let digits = text.filter { $0.isNumber }
        return String(digits.prefix(maxDigits))
    }

    /// Formats digits for display using region-specific PartialFormatter.
    func formatForDisplay(_ digits: String) -> String {
        guard !digits.isEmpty else { return "" }
        let formatter = PartialFormatter(defaultRegion: regionCode, maxDigits: maxDigits)
        return formatter.formatPartial(digits)
    }

    /// Syncs `editingText` from the bound `nationalNumber` (used on appear and when nationalNumber changes externally).
    func syncFromNationalNumber() {
        let clamped = clampToDigits(nationalNumber)
        if clamped != nationalNumber {
            nationalNumber = clamped
        }
        let formatted = formatForDisplay(clamped)
        if formatted != editingText {
            editingText = formatted
        }
    }

    /// Handles user edits: updates bound value and reformats display.
    func handleEditingTextChange(_ new: String) {
        let clamped = clampToDigits(new)
        if clamped != nationalNumber {
            nationalNumber = clamped
        }
        let formatted = formatForDisplay(clamped)
        if formatted != new {
            editingText = formatted
        }
    }
}
