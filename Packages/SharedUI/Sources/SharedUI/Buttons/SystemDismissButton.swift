//
//  SystemDismissButton.swift
//  SharedUI
//
//  Created by patrick ridd on 3/13/26.
//

import SharedUtils
import SwiftUI

public struct SystemDismissButton: ToolbarContent {
    
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                HapticManager.selection()
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
}
