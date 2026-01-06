//
//  GratitudeView.swift
//  FeatureGratitude
//
//  Created by patrick ridd on 1/2/26.
//

import SwiftUI
import Domain

public struct GratitudeView: View {
    @State private var viewModel: GratitudeViewModel
    
    public init(viewModel: GratitudeViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Streak Section
                streakHeader
                
                // Input Section
                VStack(alignment: .leading) {
                    Text("What are you grateful for?")
                        .font(.headline)
                    
                    TextField("Today I am...", text: $viewModel.entryText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...5)
                }
                
                Button {
                    Task { await viewModel.saveEntry() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Log Gratitude")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.entryText.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Mindset")
        }
    }
    
    private var streakHeader: some View {
        VStack {
            ZStack {
                // A subtle background glow
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                // The Streak Number
                VStack(spacing: -5) {
                    Text(viewModel.streakDisplay)
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("DAY STREAK")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 20)
        }
    }
}

#Preview("Empty State") {
    let mockRepo = MockGratitudeRepository(days: 0)
    let viewModel = GratitudeViewModel(
        getStreakUseCase: GetStreakUseCase(repository: mockRepo),
        addGratitudeUseCase: AddGratitudeUseCase(repository: mockRepo)
    )
    return GratitudeView(viewModel: viewModel)
}

#Preview("10 Day Streak") {
    let mockRepo = MockGratitudeRepository(days: 10)
    let useCase = GetStreakUseCase(repository: mockRepo)
    let addUseCase = AddGratitudeUseCase(repository: mockRepo)
    
    let viewModel = GratitudeViewModel(
        getStreakUseCase: useCase,
        addGratitudeUseCase: addUseCase
    )
    
    // Manual trigger for the preview
    return GratitudeView(viewModel: viewModel)
        .task {
            await viewModel.refreshStreak()
        }
}
