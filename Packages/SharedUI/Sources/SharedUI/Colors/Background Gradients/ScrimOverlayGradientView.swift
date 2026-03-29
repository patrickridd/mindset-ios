//
//  ScrimOverlayGradientView.swift
//  SharedUI
//
//  Created by patrick ridd on 3/29/26.
//
import SwiftUI

public struct ScrimOverlayGradientView: View {
    private let opacity: Double
    
    public init(opacity: Double = 0.5) {
        self.opacity = opacity
    }
    
    public var body: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.8), location: 0),     // Dark at the top
                .init(color: .black.opacity(0.4), location: 0.3),   // Fading out
                .init(color: .clear, location: 0.5)                 // Clear in the middle
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ScrimOverlayGradientView()
}
