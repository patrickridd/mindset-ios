//
//  PhoneNumberTextField.swift
//  FeatureAuth
//
//  Created by patrick ridd on 3/9/26.
//

import PhoneNumberKit
import SharedUI
import SwiftUI

struct PhoneNumberTextField: View {
    
    @Binding var nationalNumber: String
    
    let regionCode: String
    let placeholder: String
    let phoneNumberKit: PhoneNumberKit

    private var maxDigits: Int {
        PhoneNumberValidation.maxNationalDigits(phoneNumberKit: phoneNumberKit, regionCode: regionCode)
    }

    @State private var editingText: String = ""

    var body: some View {
        TextField(placeholder,
                  text: $editingText)
            .textFieldStyle(.plain)
            .font(MindsetFonts.body)
            .foregroundStyle(MindsetColors.textPrimary)
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .autocorrectionDisabled()
            .onAppear {
                let digits = nationalNumber.filter { $0.isNumber }
                if digits.isEmpty {
                    editingText = ""
                } else {
                    let formatter = PartialFormatter(defaultRegion: regionCode, maxDigits: maxDigits)
                    editingText = formatter.formatPartial(digits)
                }
            }
            .onChange(of: editingText) { new in
                // Strip to digits and clamp to max
                let digits = new.filter { $0.isNumber }
                let clamped = String(digits.prefix(maxDigits))

                // Update the bound model if needed
                if clamped != nationalNumber {
                    nationalNumber = clamped
                }

                // Reformat and push back into the field if needed
                let formatted: String
                if clamped.isEmpty {
                    formatted = ""
                } else {
                    let formatter = PartialFormatter(defaultRegion: regionCode, maxDigits: maxDigits)
                    formatted = formatter.formatPartial(clamped)
                }

                if formatted != new {
                    editingText = formatted
                }
            }
            .onChange(of: nationalNumber) { newValue in
                // Keep the UI in sync with external updates to the bound value
                let digits = newValue.filter { $0.isNumber }
                let clamped = String(digits.prefix(maxDigits))
                if clamped != newValue {
                    nationalNumber = clamped
                }

                let formatted: String
                if clamped.isEmpty {
                    formatted = ""
                } else {
                    let formatter = PartialFormatter(defaultRegion: regionCode, maxDigits: maxDigits)
                    formatted = formatter.formatPartial(clamped)
                }

                if formatted != editingText {
                    editingText = formatted
                }
            }
    }
}

