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
            // Background stays behind everything
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Static Progress Bar
                ritualProgressBar
                    .padding(.vertical)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Fetching your prompts...")
                    Spacer()
                } else if viewModel.prompts.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Prompts Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Try restarting the ritual or check your profile settings.")
                    )
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 24) {
                                ritualContent
                                
                                // Use a specific ID for the spacer to scroll to
                                Color.clear.frame(height: 20)
                                    .id("bottom-spacer")
                            }
                            .padding(.horizontal)
                        }
                        .onChange(of: viewModel.isAiThinking) { _, thinking in
                            if thinking {
                                // Delay slightly to allow keyboard/AI card to animate in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation { proxy.scrollTo("bottom-spacer", anchor: .bottom) }
                                }
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    // 3. Sticky Footer
                    // Removing .ignoresSafeArea from the ZStack lets the keyboard
                    // push this specific VStack up automatically.
                    footerButtons
                        .background(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: -5)
                        )
                }
            }
        }
        // We removed .ignoresSafeArea(.keyboard) here so the footer buttons
        // "ride" on top of the keyboard naturally.
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
