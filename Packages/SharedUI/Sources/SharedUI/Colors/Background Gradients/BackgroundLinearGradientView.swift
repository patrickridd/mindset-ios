//
//  BackgroundLinearGradientView.swift
//  SharedUI
//
//  Created by patrick ridd on 3/15/26.
//


import SwiftUI

public struct BackgroundLinearGradientView: View {
    private let opacity: Double
    
    public init(opacity: Double = 0.5) {
        self.opacity = opacity
    }
    
    public var body: some View {
        LinearGradient(
            colors: [
                MindsetColors.backgroundDark,
                MindsetColors.backgroundDarkSoft,
                MindsetColors.backgroundWarmAccent.opacity(opacity),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundLinearGradientView()
}
