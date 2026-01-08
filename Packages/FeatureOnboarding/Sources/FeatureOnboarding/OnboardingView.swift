//
//  OnboardingView.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI
import Domain

public struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var data = OnboardingData()
    @State private var isCalculating = false // For the "Reveal" transition
    
    var onComplete: () -> Void // The Coordinator will handle this transition

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    let questions = [
        "What is your primary focus right now?",
        "How often do you feel overwhelmed?",
        "What stops your consistency?",
        "What's one word for your 'Best Self'?"
    ]

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isCalculating {
                calculatingView
            } else {
                questionContent
            }
        }
    }

    private var questionContent: some View {
        VStack(spacing: 40) {
            // Progress Bar
            ProgressView(value: Double(currentStep), total: Double(questions.count))
                .progressViewStyle(.linear)
                .tint(.orange)
                .padding()

            Text(questions[currentStep])
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding()

            // Options (Example for Step 0)
            VStack(spacing: 12) {
                ForEach(["Career", "Health", "Wealth", "Inner Peace"], id: \.self) { option in
                    Button(action: {
                        // nextStep()
                        currentStep += 1
                    }) {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.3)))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 30)
        }
    }

    private var calculatingView: some View {
            VStack(spacing: 30) {
                ProgressView()
                    .tint(.orange)
                    .scaleEffect(2)
                
                Text("Building your Identity Profile...")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("• Analyzing goals").foregroundStyle(.green)
                    Text("• Calibrating Archetypes").foregroundStyle(.green)
                    Text("• Setting up Yesterday Bridge").foregroundStyle(.white.opacity(0.3))
                }
                .font(.caption)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    // TRIGGER PAYWALL HERE
                }
            }
        }
}
