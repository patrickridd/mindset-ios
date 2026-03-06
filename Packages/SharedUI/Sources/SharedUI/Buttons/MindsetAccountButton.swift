//
//  MindsetAccountButton.swift
//  SharedUI
//
//  Created by patrick ridd on 3/5/26.
//

import SwiftUI

struct MindsetAccountButton: View {

    let icon: String
    let color: Color

    @Environment(\.colorScheme) private var colorScheme

    private var iconBackgroundOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.2
    }
    
    var body: some View {
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
    MindsetAccountButton(icon: "person.crop.circle", color: MindsetColors.accentOrange)
}
