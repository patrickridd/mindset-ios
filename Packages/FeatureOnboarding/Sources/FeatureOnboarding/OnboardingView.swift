//
//  OnboardingView.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI
import Domain

public struct OnboardingView: View {

    @State private var viewModel: OnboardingViewModel
    
    public init(viewModel: OnboardingViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isCalculating {
                calculatingView
            } else {
                questionContent
            }
        }
    }

    private var questionContent: some View {
        VStack(spacing: 40) {
            // Progress Bar
            ProgressView(value: Double(viewModel.currentStep), total: Double(viewModel.questions.count))
                .progressViewStyle(.linear)
                .tint(.orange)
                .padding()

            Text(viewModel.questions[viewModel.currentStep])
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding()

            // Options (Example for Step 0)
            VStack(spacing: 12) {
                ForEach(["Career", "Health", "Wealth", "Inner Peace"], id: \.self) { option in
                    Button(action: {
                        // nextStep()
                        viewModel.currentStep += 1
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

#Preview {
    let viewModel = OnboardingViewModel(userRepository: MockUserRepository()) {
    }
    return OnboardingView(viewModel: viewModel)
}
