//
//  ShimmerPlaceholderView.swift
//  SharedUI
//
//  Created by patrick ridd on 2/15/26.
//

import SwiftUI

public struct ShimmerPlaceholderView: View {
    
    public var body: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing8) {
            RoundedRectangle(cornerRadius: MindsetLayout.radiusSmall).fill(.gray.opacity(0.2)).frame(height: MindsetLayout.spacing12)
            RoundedRectangle(cornerRadius: MindsetLayout.radiusSmall).fill(.gray.opacity(0.2)).frame(height: MindsetLayout.spacing12).padding(.trailing, MindsetLayout.spacing40)
        }
        .shimmer()
    }
}

#Preview {
    ShimmerPlaceholderView()
}
