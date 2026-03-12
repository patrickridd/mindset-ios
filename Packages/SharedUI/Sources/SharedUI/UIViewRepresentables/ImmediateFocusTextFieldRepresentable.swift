//
//  ImmediateFocusTextFieldRepresentable.swift
//  SharedUI
//
//  Created by patrick ridd on 3/12/26.
//

import SwiftUI

public struct ImmediateFocusTextFieldRepresentable: UIViewRepresentable {
    @Binding var text: String

    let placeholder: String
    let keyboardType: UIKeyboardType
    var textContentType: UITextContentType?

    public init(text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType, textContentType: UITextContentType? = nil) {
        _text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.textContentType = textContentType
    }
    
    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.textColor = UIColor(MindsetColors.textPrimary)
        textField.backgroundColor = .clear
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange),
            for: .editingChanged
        )

        UIView.performWithoutAnimation {
            textField.becomeFirstResponder()
        }

        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    public final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        @objc func textDidChange(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

// MARK: - Layout
extension ImmediateFocusTextFieldRepresentable {

    /// Returns the desired text field height for the given Dynamic Type category.
    static public func textFieldHeight(for sizeCategory: ContentSizeCategory) -> CGFloat {
        switch sizeCategory {
        case .extraSmall, .small, .medium:
            return 40
        case .large:
            return 44
        case .extraLarge:
            return 48
        case .extraExtraLarge:
            return 52
        case .extraExtraExtraLarge:
            return 56
        case .accessibilityMedium:
            return 60
        case .accessibilityLarge:
            return 64
        case .accessibilityExtraLarge:
            return 68
        case .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return 72
        @unknown default:
            return 44
        }
    }
}
