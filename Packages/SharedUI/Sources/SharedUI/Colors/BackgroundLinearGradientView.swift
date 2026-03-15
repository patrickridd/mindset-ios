//
//  BackgroundLinearGradientView.swift
//  SharedUI
//
//  Created by patrick ridd on 3/15/26.
//


import SwiftUI

public struct BackgroundLinearGradientView: View {
    
    public init() {}
    
    public var body: some View {
        LinearGradient(
            colors: [
                MindsetColors.backgroundDark,
                MindsetColors.backgroundDarkSoft,
                MindsetColors.backgroundWarmAccent.opacity(0.5),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
