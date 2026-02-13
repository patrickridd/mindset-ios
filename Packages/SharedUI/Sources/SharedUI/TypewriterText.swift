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
    let characterDelay: TimeInterval
    let isHapticFeedbackEnabled: Bool
    let onComplete: (() -> Void)?
    
    @State private var displayedText: String = ""
    @State private var animationTask: Task<Void, Never>?
    
    public init(
        text: String,
        font: Font,
        color: Color,
        characterDelay: TimeInterval = 0.06,
        isHapticFeedbackEnabled: Bool = true,
        onComplete: (() -> Void)? = nil
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.characterDelay = characterDelay
        self.isHapticFeedbackEnabled = isHapticFeedbackEnabled
        self.onComplete = onComplete
    }
    
    public var body: some View {
        Text(displayedText)
            .font(font)
            .foregroundStyle(color)
            .task {
                await animateText()
            }
            .onDisappear {
                animationTask?.cancel()
            }
            .padding(.horizontal)
    }
    
    private func animateText() async {
        // Cancel any existing animation
        animationTask?.cancel()
        
        // Create new animation task
        animationTask = Task { @MainActor in
            displayedText = ""
            
            for character in text {
                // Check for cancellation between characters
                guard !Task.isCancelled else {
                    return
                }
                
                // Add character
                displayedText.append(character)
                
                // Trigger haptic for each character (light, non-intrusive)
                if isHapticFeedbackEnabled {
                    HapticManager.selection()
                }
                
                // Wait before next character
                try? await Task.sleep(for: .milliseconds(Int(characterDelay * 1000)))
            }
            
            // Animation complete
            onComplete?()
        }
        
        await animationTask?.value
    }
}

// MARK: - Preview

#Preview("Typewriter Animation") {
    VStack(spacing: 40) {
        TypewriterText(
            text: "What are three things you're grateful for today?",
            font: .title2,
            color: .primary,
            characterDelay: 0.06
        )
        .multilineTextAlignment(.leading)
        .padding()
        
        TypewriterText(
            text: "Reflect on a moment when you felt truly present.",
            font: .body,
            color: .secondary,
            characterDelay: 0.05
        )
        .multilineTextAlignment(.leading)
        .padding()
    }
}
