//
//  TypewriterText.swift
//  SharedUI
//
//  Character-by-character text reveal animation with haptic feedback.
//  Follows ChatGPT-style typewriter effect (2024-2026 best practices).
//

import SharedUtils
import SwiftUI

/// A text view that reveals characters one at a time with haptic feedback.
/// Uses modern async/await pattern with Task for timing and lifecycle management.
public struct TypewriterText: View {
    let text: String
    let font: Font
    let color: Color
    let isHapticEnabled: Bool
    let onComplete: (() -> Void)?
    
    @State private var displayedText: String = ""
    @State private var isTypingActive: Bool = false
    @State private var isThinking: Bool = false
    
    public init(
        text: String,
        font: Font,
        color: Color,
        isHapticEnabled: Bool = true,
        onComplete: (() -> Void)? = nil
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.isHapticEnabled = isHapticEnabled
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(text)
                    .font(font)
                    .opacity(0)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(displayedText)
                    .font(font)
            }
        }
        .task(id: text) {
            await animateSequence()
        }
    }
    
    private func animateSequence() async {
        displayedText = ""
       
        withAnimation {
            isTypingActive = true
        }

        HapticManager.prepareTypewriter()
        HapticManager.action() // Initial "Let's go" tap
        
        let words = text.components(separatedBy: " ")
        for (index, word) in words.enumerated() {
            if Task.isCancelled { break }
            
            displayedText += word + (index == words.count - 1 ? "" : " ")
            triggerSmartHaptic(for: word)
            
            let delay = word.contains(".") ? 300 : 60
            try? await Task.sleep(for: .milliseconds(55))
        }
        
        isTypingActive = false

        onComplete?()
    }

    private func triggerSmartHaptic(for word: String) {
        guard isHapticEnabled else { return }
        if word.contains(".") || word.contains("?") {
            HapticManager.typewriterEmphasis()
        } else {
            HapticManager.typewriterTick()
        }
    }
}

// MARK: - Preview

#Preview("Typewriter Animation") {
    VStack(spacing: 40) {
        TypewriterText(
            text: "What are three things you're grateful for today? Think about them carefully.",
            font: .title2,
            color: .primary,
            isHapticEnabled: true,
            onComplete: nil
        )
        .multilineTextAlignment(.leading)
        .padding()
        
        TypewriterText(
            text: "Reflect on a moment when you felt truly present.",
            font: .body,
            color: .secondary,
            isHapticEnabled: false,
            onComplete: nil
        )
        .multilineTextAlignment(.leading)
        .padding()
    }
}
