//
//  TypewriterText.swift
//  SharedUI
//
//  Word-by-word text reveal animation with haptic feedback.
//  Follows ChatGPT-style typewriter effect (2024-2026 best practices).
//

import SharedUtils
import SwiftUI

/// A text view that reveals words one at a time with haptic feedback.
/// Uses modern async/await pattern with Task for timing and lifecycle management.
public struct TypewriterText: View {
    let text: String
    let font: Font
    let color: Color
    let isHapticEnabled: Bool
    let onComplete: (() -> Void)?
    
    @State private var displayedText: String = ""
    @State private var isAnimating: Bool = false
    @State private var showCursor: Bool = false
    
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    
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
        Text(text)
            .font(font)
            .foregroundStyle(color)
            .opacity(0)
            .overlay(alignment: .topLeading) {
                Text(displayedText + (isAnimating && showCursor ? "▌" : ""))
                    .font(font)
                    .foregroundStyle(color)
                    .contentTransition(.opacity)
                    .animation(.easeIn(duration: 0.06), value: displayedText)
            }
            .task(id: text) {
                await animateSequence()
            }
    }
    
    private func animateSequence() async {
        displayedText = ""
        
        if accessibilityReduceMotion {
            displayedText = text
            onComplete?()
            return
        }
        
        isAnimating = true
        let cursorBlink = Task { @MainActor in
            while !Task.isCancelled {
                showCursor.toggle()
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
        
        HapticManager.prepareTypewriter()
        HapticManager.action() // Initial "Let's go" tap
        
        let words = text.components(separatedBy: " ")
        for (index, word) in words.enumerated() {
            if Task.isCancelled { break }
            
            displayedText += word + (index == words.count - 1 ? "" : " ")
            triggerSmartHaptic(for: word)
            
            let delay = delay(for: word) + Int.random(in: -12...12)
            try? await Task.sleep(for: .milliseconds(max(30, delay)))
        }
        
        cursorBlink.cancel()
        showCursor = false
        isAnimating = false
        
        try? await Task.sleep(for: .milliseconds(80)) // Wait for last word to fade in
        
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

    private func delay(for word: String) -> Int {
        if word.contains(".") {
            return 300
        } else if word.contains("!") || word.contains("?") {
            return 200
        } else if word.contains(";") || word.contains(":") {
            return 150
        } else if word.contains(",") {
            return 100
        } else {
            return 55
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