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
            
            VStack(spacing: 0) {
                // 1. Static Progress Bar (Stays at the top)
                ritualProgressBar
                    .padding(.vertical)

                // 2. Scrollable Content
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            ritualContent
                            
                            // This empty space ensures we can scroll high enough
                            // to see the AI card above the keyboard
                            Color.clear.frame(height: 100)
                                .id("bottom-spacer")
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.isAiThinking) { _, thinking in
                        if thinking {
                            withAnimation { proxy.scrollTo("bottom-spacer", anchor: .bottom) }
                        }
                    }
                }
                
                // 3. Sticky Footer Button
                footerButtons
                    .background(Color(uiColor: .systemGroupedBackground)) // Cover content behind
            }
        }
        // This allows the keyboard to push the view up properly
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
                textEditor(promptId: prompt.id)
                
                if viewModel.isAiThinking || viewModel.aiReflection != nil {
                    AIReflectionCard(
                        reflection: viewModel.aiReflection,
                        isThinking: viewModel.isAiThinking
                    )
                    .padding(.top)
                }
                
                // Add a button to trigger AI or auto-trigger on "Continue"
                if !viewModel.isAiThinking && viewModel.aiReflection == nil {
                    Button("Get Feedback") {
                        Task { await viewModel.submitCurrentAnswer() }
                    }
                    .buttonStyle(.borderless)
                    .tint(.orange)
                    .disabled(!viewModel.canProceed)
                }

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

    func textEditor(promptId: String) -> some View {
        TextEditor(text: Binding(
            get: { viewModel.answers[promptId] ?? "" },
            set: { viewModel.answers[promptId] = $0 }
        ))
        .frame(minHeight: 150, maxHeight: .infinity)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .secondarySystemGroupedBackground)))
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
            let checkmark: String = viewModel.canProceed ? "✅" : "☑️"
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.nextStep()
                }
            }) {
                HStack {
                    Text(isLastStep ? "Complete \(checkmark)" : "Next Step")
                    if !isLastStep {
                        Image(systemName:  "chevron.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .bold()
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
