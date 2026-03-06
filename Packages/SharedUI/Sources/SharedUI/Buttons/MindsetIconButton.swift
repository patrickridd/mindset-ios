//
//  MindsetAccountButton.swift
//  SharedUI
//
//  Created by patrick ridd on 3/5/26.
//

import SwiftUI

public struct MindsetIconButton: View {

    let icon: String
    let color: Color

    @Environment(\.colorScheme) private var colorScheme

    private var iconBackgroundOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.2
    }
    
    public init(icon: String, color: Color) {
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(iconBackgroundOpacity))
                .frame(
                    width: MindsetLayout.iconButtonLarge,
                    height: MindsetLayout.iconButtonLarge
                )

            Image(systemName: icon)
                .font(.system(size: MindsetLayout.iconLarge))
                .foregroundStyle(color)
        }
    }
}

#Preview {
    MindsetIconButton(icon: "person.crop.circle", color: MindsetColors.accentOrange)
}
