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
        ZStack {
            content
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                        Label(isExpanded ? "Close" : "Debug", systemImage: "terminal")
                            .font(.caption2.bold())
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius: 2)
                    }
                }

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
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 60) // Stay clear of the Dynamic Island
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
