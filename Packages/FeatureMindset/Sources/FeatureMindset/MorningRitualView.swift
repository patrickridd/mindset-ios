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
                    ritualStep(
                        title: "What are you grateful for?", 
                        text: $viewModel.gratitudeText
                    ).tag(MorningRitualViewModel.RitualStep.gratitude)
                    
                    ritualStep(
                        title: "What is your goal for today?", 
                        text: $viewModel.goalText
                    ).tag(MorningRitualViewModel.RitualStep.goal)
                    
                    ritualStep(
                        title: "What is your affirmation?", 
                        text: $viewModel.affirmationText
                    ).tag(MorningRitualViewModel.RitualStep.affirmation)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)
                
                footerButtons
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingSuccess) {
            RitualSuccessView(archetype: viewModel.generatedArchetype ?? "The Resilient") {
                // Handle dismissal (e.g., go back to Dashboard)
            }
        }
        .animation(.spring(), value: viewModel.isShowingSuccess)
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
                Button("Complete Ritual") {
                    Task { await viewModel.completeRitual() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            } else {
                Button("Next") {
                    withAnimation { viewModel.nextStep() }
                }
                .buttonStyle(.bordered)
            }
        }
        .sensoryFeedback(.success, trigger: viewModel.isShowingSuccess)
        .padding()
        .disabled(viewModel.isLoading)
    }
}

#Preview("Morning Ritual - Day 2") {
    // We create 2 days of data so that "Yesterday" exists
    let mockRepo = MockMindsetRepository(days: 2)
    
    let viewModel = MorningRitualViewModel(
        addMindsetUseCase: AddMindsetUseCase(repository: mockRepo),
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase(repository: mockRepo)
    )
    
    return MorningRitualView(viewModel: viewModel)
}
