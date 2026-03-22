//
//  MindsetAccountButton.swift
//  SharedUI
//
//  Created by patrick ridd on 3/5/26.
//

import SwiftUI

public struct MindsetIconView: View {

    let icon: String
    let color: Color
    let circleSize: CGFloat
    let iconSize: CGFloat
    let leadingPadding: CGFloat
    let sizeRatio: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private var iconBackgroundOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.2
    }

    public init(
        icon: String,
        color: Color,
        circleSize: CGFloat = MindsetLayout.iconButtonLarge,
        iconSize: CGFloat = MindsetLayout.iconLarge,
        sizeRatio: CGFloat = 1.0,
        leadingPadding: CGFloat = 0
    ) {
        self.icon = icon
        self.color = color
        self.circleSize = circleSize
        self.iconSize = iconSize
        self.sizeRatio = sizeRatio
        self.leadingPadding = leadingPadding
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(iconBackgroundOpacity))
                .frame(
                    width: circleSize * sizeRatio,
                    height: circleSize * sizeRatio
                )

            Image(systemName: icon)
                .font(.system(size: iconSize * sizeRatio))
                .foregroundStyle(color)
                .padding(.leading, leadingPadding)
        }
    }
}


#Preview("Delete") {
    MindsetIconView(
        icon: "trash",
        color: MindsetColors.accentDestructiveRed,
        iconSize: 20
    )
}

#Preview("Sign Out") {
    MindsetIconView(
        icon: "rectangle.portrait.and.arrow.forward",
        color: MindsetColors.accentOrange,
        iconSize: 20,
        leadingPadding: 5
    )
}
