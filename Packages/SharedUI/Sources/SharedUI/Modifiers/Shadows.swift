import SwiftUI

public extension View {
    /// The "magic line" shadow used across StartView.
    @inlinable
    func elevatedShadow() -> some View {
        self.shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
    }

    /// A configurable variant if you need to tweak parameters per-call.
    @inlinable
    func mindsetShadow(color: Color = .black.opacity(0.6),
                       radius: CGFloat = 4,
                       x: CGFloat = 0,
                       y: CGFloat = 2) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }

    /// A convenient shadow for light-on-dark text to add subtle glow.
    @inlinable
    func textGlowShadow() -> some View {
        self.shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
    }
}
