//
//  MorningRitualView.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/6/26.
//

import Domain
import SwiftUI

public struct MorningRitualView: View {
    @State private var viewModel: MorningRitualViewModel
    
    public init(viewModel: MorningRitualViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            // Background: Subtle Gradient for "Grounding"
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                // Progress Indicator
                 ritualProgressBar
                    .padding(.top)
                
                TabView(selection: $viewModel.currentStep) {
                    ritualStep(title: "What are you grateful for?", text: $viewModel.gratitudeText)
                        .tag(MorningRitualViewModel.RitualStep.gratitude)
                        
                    ritualStep(title: "What is your goal for today?", text: $viewModel.goalText)
                        .tag(MorningRitualViewModel.RitualStep.goal)

                    ritualStep(title: "What is your affirmation?", text: $viewModel.affirmationText)
                        .tag(MorningRitualViewModel.RitualStep.affirmation)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.default, value: viewModel.canProceed)
                .sensoryFeedback(.impact(weight: .light), trigger: viewModel.canProceed) { old, new in
                    new == true // Give a tiny 'click' feel when the swipe is enabled
                }
                footerButtons
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingSuccess) {
            RitualSuccessView(archetype: viewModel.generatedArchetype ?? "The Resilient") {
                // Handle dismissal (e.g., go back to Dashboard)
                viewModel.isShowingSuccess = false
            }
        }
        .animation(.spring(), value: viewModel.isShowingSuccess)
    }
    
    private func moveBack() {
        if let previous = MorningRitualViewModel.RitualStep(rawValue: viewModel.currentStep.rawValue - 1) {
            viewModel.currentStep = previous
        }
    }

    // MARK: - Subviews
    
    private func ritualStep(title: String, text: Binding<String>) -> some View {
        VStack(spacing: 20) {
            if let yesterday = viewModel.yesterdayGoal, viewModel.currentStep == .gratitude {
                VStack(alignment: .leading) {
                    Text("YESTERDAY'S FOCUS")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    Text(yesterday)
                        .font(.subheadline)
                        .italic()
                }
                .padding()
                .background(Capsule().stroke(Color.orange.opacity(0.3)))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Text(title)
                .font(.system(.title, design: .serif))

            TextEditor(text: text)
                .frame(height: 150)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle()) // Makes the background hittable
        .gesture(
            DragGesture().onEnded { value in
                let threshold: CGFloat = 50
                
                // CASE 1: Swiping BACK (Right Swipe -> Positive Width)
                if value.translation.width > threshold {
                    withAnimation {
                        moveBack() // Always allow going back
                    }
                }
                
                // CASE 2: Swiping FORWARD (Left Swipe -> Negative Width)
                if value.translation.width < -threshold {
                    if viewModel.canProceed {
                        withAnimation {
                            viewModel.nextStep() // Only allow if valid
                        }
                    } else {
                        // Optional: Trigger a "rejection" haptic here
                    }
                }
            }
        )
    }
    
    private var ritualProgressBar: some View {
        HStack {
            ForEach(MorningRitualViewModel.RitualStep.allCases, id: \.self) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue ? Color.orange : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
    }
    
    private var footerButtons: some View {
        VStack {
            if viewModel.currentStep == .affirmation {
                Button("Complete Mindset") {
                    Task { await viewModel.completeRitual() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canProceed || viewModel.isLoading)
                .sensoryFeedback(.selection, trigger: viewModel.currentStep)
                .sensoryFeedback(.impact(weight: .light), trigger: viewModel.canProceed) { old, new in
                    return new == true // Only vibrate when it BECOMES valid
                }
            } else {
                Button("Next Step") {
                    withAnimation(.spring()) {
                        viewModel.nextStep()
                    }
                }
                .buttonStyle(.bordered)
                // The "Gatekeeper" in action
                .disabled(!viewModel.canProceed)
                .opacity(viewModel.canProceed ? 1.0 : 0.5)
                .sensoryFeedback(.selection, trigger: viewModel.currentStep)
                .sensoryFeedback(.impact(weight: .light), trigger: viewModel.canProceed) { old, new in
                    return new == true // Only vibrate when it BECOMES valid
                }
            }
        }
        .padding()
        .animation(.default, value: viewModel.canProceed)
    }

    private var forwardLockGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                // Only 'trap' if swiping LEFT (forward)
                if value.translation.width < 0 {
                    // The highPriorityGesture is active, blocking the TabView
                }
            }
    }
}

#Preview("Morning Ritual - Day 2") {
    // We create 2 days of data so that "Yesterday" exists
    let mockRepo = MockMindsetRepository(days: 2)
    let viewModel = MorningRitualViewModel(
        addMindsetUseCase: AddMindsetUseCase(repository: mockRepo),
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase(repository: mockRepo),
        subscriptionService: MockSubscriptionService()
    )
    return MorningRitualView(viewModel: viewModel)
}

#Preview("Free User Flow") {
    let mockRepo = MockMindsetRepository(days: 0)
    let viewModel = MorningRitualViewModel(
        addMindsetUseCase: AddMindsetUseCase(repository: mockRepo),
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase(repository: mockRepo),
        subscriptionService: MockSubscriptionService(isPro: false)
    )
    return MorningRitualView(viewModel: viewModel)
}

#Preview("Pro User Flow") {
    let mockRepo = MockMindsetRepository(days: 0)
    let viewModel = MorningRitualViewModel(
        addMindsetUseCase: AddMindsetUseCase(repository: mockRepo),
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase(repository: mockRepo),
        subscriptionService: MockSubscriptionService(isPro: true)
    )
    return MorningRitualView(viewModel: viewModel)
}
