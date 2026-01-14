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
                // 1. Static Progress Bar
                ritualProgressBar
                    .padding(.vertical)

                // 2. Scrollable Content Area
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            ritualContent
                            
                            // Bottom anchor for keyboard scrolling
                            Color.clear.frame(height: 20)
                                .id("bottom-spacer")
                        }
                        .padding(.horizontal)
                    }
                    // Auto-scroll when AI starts thinking or provides a reflection
                    .onChange(of: viewModel.isAiThinking) { _, thinking in
                        if thinking {
                            withAnimation { proxy.scrollTo("bottom-spacer", anchor: .bottom) }
                        }
                    }
                }
                
                // 3. Sticky Footer Button
                footerButtons
                    .background(Color(uiColor: .systemGroupedBackground).shadow(radius: 2, y: -2))
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var ritualContent: some View {
        if let prompt = viewModel.currentPrompt {
            VStack(spacing: 24) {
                // Yesterday Bridge
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
                
                // AI Section (Pulls from currentAiReflection computed property)
                if viewModel.isAiThinking || viewModel.currentAiReflection != nil {
                    AIReflectionCard(
                        reflection: viewModel.currentAiReflection,
                        isThinking: viewModel.isAiThinking
                    )
                    .padding(.top)
                }
                
                // Feedback Trigger
                if !viewModel.isAiThinking && viewModel.currentAiReflection == nil {
                    Button(action: {
                        Task { await viewModel.submitCurrentAnswer() }
                    }) {
                        Label("Get AI Reflection", systemImage: "sparkles")
                            .font(.subheadline).bold()
                    }
                    .buttonStyle(.borderless)
                    .tint(.orange)
                    .disabled(!viewModel.canProceed)
                }

                // Coach Tip
                coachTipView(tip: prompt.coachTip)
                
                Spacer(minLength: 50)
            }
            // Transition for "Duolingo" slide effect
            .id(prompt.id)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }

    private func textEditor(promptId: String) -> some View {
        TextEditor(text: Binding(
            get: { viewModel.answers[promptId] ?? "" },
            set: { viewModel.answers[promptId] = $0 }
        ))
        // Fixed height prevents the "shrinking" issue when keyboard appears
        .frame(minHeight: 120)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .secondarySystemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.orange.opacity(0.1), lineWidth: 1))
    }
    
    private func coachTipView(tip: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Coach Tip", systemImage: "lightbulb.fill")
                .font(.caption).bold()
                .foregroundStyle(.orange)
            Text(tip)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.05)))
    }
    
    private func yesterdayBridge(text: String) -> some View {
        VStack(alignment: .leading) {
            Text("YESTERDAY'S FOCUS").font(.caption2).bold().foregroundStyle(.orange)
            Text(text).font(.subheadline).italic().lineLimit(2)
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
                    Text(isLastStep ? "Complete \(checkmark)" : "Continue")
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .bold()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!viewModel.canProceed || viewModel.isAiThinking)
            .padding()
        }
    }
}
