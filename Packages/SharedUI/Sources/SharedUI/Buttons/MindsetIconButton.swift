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
    let circleWidthHeight: CGFloat
    let iconFont: Font
    let leadingPadding: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme

    private var iconBackgroundOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.2
    }

    public init(
        icon: String,
        color: Color,
        circleWidthHeight: CGFloat = MindsetLayout.iconButtonLarge,
        iconFont: Font = MindsetFonts.mindsetIconButtonFont,
        leadingPadding: CGFloat = 0
    ) {
        self.icon = icon
        self.color = color
        self.circleWidthHeight = circleWidthHeight
        self.iconFont = iconFont
        self.leadingPadding = leadingPadding
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(iconBackgroundOpacity))
                .frame(
                    width: circleWidthHeight,
                    height: circleWidthHeight
                )

            Image(systemName: icon)
                .font(iconFont)
                .foregroundStyle(color)
                .padding(.leading, leadingPadding)
        }
    }
}


#Preview("Delete") {
    MindsetIconButton(
        icon: "trash",
        color: MindsetColors.accentDestructiveRed,
    )
}

#Preview("Sign Out") {
    MindsetIconButton(
        icon: "rectangle.portrait.and.arrow.forward",
        color: MindsetColors.accentOrange,
        leadingPadding: 5
    )
}
