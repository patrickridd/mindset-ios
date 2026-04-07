//
//  GratitudeSlotView.swift
//  FeatureMindset
//
//  Created by patrick ridd on 4/5/26.
//

import Domain
import SharedUI
import SwiftUI

struct GratitudeSlotView: View {
    @Environment(\.colorScheme) var colorScheme

    let index: Int
    let text: String
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 12) {
            // The Progress Indicator
            ZStack {
                Circle()
                    .fill(isCompleted ? MindsetColors.accentOrange : Color.clear)
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(MindsetColors.accentOrange, lineWidth: 2))
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(index + 1)")
                        .font(MindsetFonts.captionBold)
                        .foregroundColor(isActive ? MindsetColors.accentOrange : .gray)
                }
            }

            // The Content Box
            Text(text.isEmpty && isActive ? "Type here..." : (text.isEmpty ? "" : text))
                .font(MindsetFonts.body)
                .foregroundColor(isActive ? .primary : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isActive ? MindsetColors.accentOrange.opacity(0.1) : MindsetColors.backgroundSecondary(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? MindsetColors.accentOrange : Color.clear, lineWidth: 2)
                )
        }
        .scaleEffect(isActive ? 1.03 : 1.0)
        .opacity(isActive || isCompleted ? 1.0 : 0.6)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
    }
}
