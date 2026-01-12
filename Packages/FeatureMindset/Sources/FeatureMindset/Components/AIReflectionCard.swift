//
//  AIReflectionCard.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/11/26.
//


import SwiftUI

struct AIReflectionCard: View {
    let reflection: String?
    let isThinking: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                Text("AI REFLECTION")
                    .font(.caption2).bold()
                    .tracking(1)
            }
            
            if isThinking {
                // Shimmering placeholder logic
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.2)).frame(height: 12)
                    RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.2)).frame(height: 12).padding(.trailing, 40)
                }
                .shimmer() // We'll add this modifier below
            } else if let reflection = reflection {
                Text(reflection)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.orange.opacity(0.2), lineWidth: 1))
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .mask(content)
    }
}
