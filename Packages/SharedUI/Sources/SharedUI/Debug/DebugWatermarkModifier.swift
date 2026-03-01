//
//  DebugWatermarkModifier.swift
//  SharedUI
//
//  Created by patrick ridd on 3/1/26.
//

import Domain
import SwiftUI

public struct DebugWatermarkModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            #if DEBUG
            VStack {
                HStack {
                    Spacer()
                    Text(DebugSettings.shared.useMocks ? "🧪 MOCK MODE" : "🌐 REAL SERVICES")
                        .font(MindsetFonts.debugFont.bold())
                        .foregroundStyle(DebugSettings.shared.useMocks ? .purple : .orange)
//                        .glassEffect(.regular, in: .capsule) // Using your Liquid Glass style
                        .opacity(0.2)
                }
                .padding(.trailing, MindsetLayout.paddingMedium)
                .padding(.top)
                Spacer()
            }
            .allowsHitTesting(false) // CRITICAL: Clicks pass through the watermark
            #endif
        }
    }
}

public extension View {
    func withEnvWatermark() -> some View {
        self.modifier(DebugWatermarkModifier())
    }
}
