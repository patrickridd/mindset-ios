//
//  DebugWatermarkModifier.swift
//  SharedUI
//
//  Created by patrick ridd on 3/1/26.
//

import Domain
import SharedUI
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
                    Text(DebugSettings.shared.useMocks ? "🧪 MOCK MODE" : "🌐 PROD MODE")
                        .font(MindsetFonts.debugFont.bold())
                        .foregroundStyle(DebugSettings.shared.useMocks ? .purple : .orange)
                        .opacity(0.2)
                    Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
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
