//
//  VignetteBackgroundView.swift
//  FeatureStart
//
//  Created by patrick ridd on 3/28/26.
//

import SwiftUI

public struct VignetteBackgroundView: View {
    public init() {}
    
    public var body: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.8), location: 0),   // Dark at the top for header
                .init(color: .clear, location: 0.4),            // Clear in the middle for the Lottie
                .init(color: .black.opacity(0.7), location: 1)    // Dark at bottom for buttons
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    VignetteBackgroundView()
}
                    
