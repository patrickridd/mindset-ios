//
//  DebugOverlay.swift
//  SharedUI
//
//  Created by patrick ridd on 1/25/26.
//

import SharedUI
import SharedUtils
import SwiftUI

public struct DebugOverlay: ViewModifier {
    @State private var isExpanded = false
    private let logger = DebugLogger.shared

    public init() {}

    public func body(content: Content) -> some View {
        #if DEBUG
            content
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        toggleButton
                        if isExpanded {
                            logPanel
                                .padding(.top, MindsetLayout.spacing4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.leading, MindsetLayout.paddingLarge)
                    .allowsHitTesting(true)
                }
        #else
            content
        #endif
    }
}

// MARK: - Subviews

private extension DebugOverlay {
    var toggleButton: some View {
        Button {
            withAnimation(.spring(response: 0.35)) { isExpanded.toggle() }
        } label: {
            Image(systemName: isExpanded ? "xmark.circle.fill" : "terminal.fill")
                .font(MindsetFonts.debugFont.weight(.medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .frame(
                    width: MindsetLayout.iconExtraLarge,
                    height: MindsetLayout.iconExtraLarge
                )
                .background(Circle().fill(.ultraThinMaterial))
        }
        .buttonStyle(.plain)
        .frame(minWidth: MindsetLayout.iconMedium, minHeight: MindsetLayout.iconMedium)
    }

    var logPanel: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MindsetLayout.spacing8) {
                ForEach(logger.logs, id: \.self) { log in
                    logRow(log)
                }
            }
            .padding(MindsetLayout.paddingSmall)
        }
        .frame(maxHeight: Constants.panelMaxHeight)
        .frame(maxWidth: Constants.panelMaxWidth)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: MindsetLayout.radiusStandard))
    }

    func logRow(_ log: String) -> some View {
        Text(log)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .font(MindsetFonts.debugFont)
            .foregroundStyle(.primary)
            .padding(MindsetLayout.paddingSmall)
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: MindsetLayout.radiusSmall))
            .frame(maxHeight: Constants.panelMaxHeight)
    }
}

// MARK: - Constants

private extension DebugOverlay {
    enum Constants {
        static let panelMaxHeight: CGFloat = 200
        static let panelMaxWidth: CGFloat = 320
    }
}

// MARK: - View Extension

public extension View {
    func withDebugOverlay() -> some View {
        self.modifier(DebugOverlay())
    }
}
