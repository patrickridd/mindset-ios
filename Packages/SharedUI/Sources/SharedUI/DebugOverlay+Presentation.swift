//
//  DebugOverlay+Presentation.swift
//  SharedUI
//
//  Created by patrick ridd on 2/28/26.
//

import SwiftUI

public extension View {
    func debugSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        sheet(item: item, onDismiss: onDismiss) { item in
            content(item)
                .withDebugOverlay()
        }
    }

    func debugFullScreenCover<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        fullScreenCover(item: item, onDismiss: onDismiss) { item in
            content(item)
                .withDebugOverlay()
        }
    }
}
