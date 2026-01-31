//
//  DebugOverlay.swift
//  SharedUI
//
//  Created by patrick ridd on 1/25/26.
//

import SwiftUI
import SharedUtils

public struct DebugOverlay: ViewModifier {
    @State private var isExpanded = false
    private var logger = DebugLogger.shared
    
    public init() {}
    
    public func body(content: Content) -> some View {
        #if DEBUG
        content
            .overlay(alignment: .topLeading) {
                // Keep trigger below status bar (no ignoresSafeArea) so touches are delivered
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: { withAnimation(.spring(response: 0.35)) { isExpanded.toggle() } }) {
                        Image(systemName: isExpanded ? "xmark.circle.fill" : "terminal.fill")
                            .font(.system(size: 12, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                            .background(.ultraThinMaterial, in: Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 44, minHeight: 44)

                    if isExpanded {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(logger.logs, id: \.self) { log in
                                    Text(log)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(100)
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.primary)
                                        .padding(6)
                                        .background(Color.primary.opacity(0.05))
                                        .cornerRadius(4)
                                        .frame(maxHeight: 200)
                                }
                            }
                            .padding(8)
                        }
                        .frame(maxHeight: 200)
                        .frame(maxWidth: 320)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.top, 4)
                        .padding(.leading, 0)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                    }
                }
                .padding(.leading, UIScreen.main.bounds.width/2 - 8)
                .padding(.top, -16)
                .allowsHitTesting(true)
            }
        #else
        content
        #endif
    }
}

public extension View {
    func withDebugOverlay() -> some View {
        self.modifier(DebugOverlay())
    }
}
