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
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Preparing your ritual...")
            } else {
                VStack {
                    ritualProgressBar
                        .padding(.top)
                    
                    // The dynamic content area
                    ritualContent
                        .animation(.default, value: viewModel.currentStepIndex)
                    
                    footerButtons
                }
            }
        }
        // Bridge the ViewModel paywall state to the View
        .sheet(isPresented: $viewModel.isShowingPaywall) {
            // Your PaywallView here
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var ritualContent: some View {
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: 24) {
                // Yesterday Bridge (Only show on first step)
                if viewModel.currentStepIndex == 0, let yesterday = viewModel.yesterdayGoal {
                    yesterdayBridge(text: yesterday)
                }
                
                // Prompt Header
                VStack(spacing: 8) {
                    Text(prompt.category.displayName.uppercased())
                        .font(.caption2)
                        .fontWeight(.black)
                        .tracking(2)
                        .foregroundStyle(.orange)
                    
                    Text(prompt.headline)
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.bold)
                }
                
                Text(prompt.questionText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Input Area
                TextEditor(text: Binding(
                    get: { viewModel.answers[prompt.id] ?? "" },
                    set: { viewModel.answers[prompt.id] = $0 }
                ))
                .frame(maxHeight: 200)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .padding(.horizontal)
                
                // Science/Coach Tip
                VStack(alignment: .leading, spacing: 5) {
                    Label("Coach Tip", systemImage: "lightbulb.fill")
                        .font(.caption).bold()
                        .foregroundStyle(.orange)
                    Text(prompt.coachTip)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.1)))
                .padding(.horizontal)
                
                Spacer()
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }
    
    private func yesterdayBridge(text: String) -> some View {
        VStack(alignment: .leading) {
            Text("YESTERDAY'S FOCUS").font(.caption2).bold().foregroundStyle(.orange)
            Text(text).font(.subheadline).italic()
        }
        .padding()
        .background(Capsule().stroke(Color.orange.opacity(0.3)))
    }
    
    private var ritualProgressBar: some View {
        HStack {
            ForEach(0..<viewModel.prompts.count, id: \.self) { index in
                Capsule()
                    .fill(index <= viewModel.currentStepIndex ? Color.orange : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .animation(.spring(), value: viewModel.currentStepIndex)
            }
        }
        .padding(.horizontal)
        .animation(.spring(duration: 0.4, bounce: 0.3), value: viewModel.currentStepIndex)
    }
    
    private var footerButtons: some View {
        VStack {
            let isLastStep = viewModel.currentStepIndex == viewModel.prompts.count - 1
            
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.nextStep()
                }
            }) {
                HStack {
                    Text(isLastStep ? "Complete Ritual" : "Next Step")
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!viewModel.canProceed)
            .padding()
        }
    }
}

#Preview("Morning Ritual - Day 2") {
    // We create 2 days of data so that "Yesterday" exists
    let mockRepo = MockMindsetRepository(days: 2)
    let viewModel = MorningRitualViewModel(
        userRepository: MockUserRepository(),
        addMindsetUseCase: AddMindsetUseCase(repository: mockRepo),
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase(repository: mockRepo),
        subscriptionService: MockSubscriptionService()
    )
    return MorningRitualView(viewModel: viewModel)
}

#Preview("Free User Flow") {
    let mockRepo = MockMindsetRepository(days: 0)
    let viewModel = MorningRitualViewModel(
        userRepository: MockUserRepository(),
        addMindsetUseCase: AddMindsetUseCase(repository: mockRepo),
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase(repository: mockRepo),
        subscriptionService: MockSubscriptionService(isPro: false)
    )
    return MorningRitualView(viewModel: viewModel)
}

#Preview("Pro User Flow") {
    let mockRepo = MockMindsetRepository(days: 0)
    let viewModel = MorningRitualViewModel(
        userRepository: MockUserRepository(),
        addMindsetUseCase: AddMindsetUseCase(repository: mockRepo),
        getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase(repository: mockRepo),
        subscriptionService: MockSubscriptionService(isPro: true)
    )
    return MorningRitualView(viewModel: viewModel)
}
