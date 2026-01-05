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
                VStack {
                    Text(viewModel.streakDisplay)
                        .font(.system(size: 80))
                    Text("DAY STREAK")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
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
}

#Preview {
    // Build a simple, non-throwing view model for previews
    let streakUseCase = GetStreakUseCase(repository: GratitudeRepositoryStub())
    let addGratitudeUseCase = AddGratitudeUseCase(repository: GratitudeRepositoryStub())
    let viewModel = GratitudeViewModel(getStreakUseCase: streakUseCase, addGratitudeUseCase: addGratitudeUseCase)
    GratitudeView(viewModel: viewModel)
}

private class GratitudeRepositoryStub: GratitudeRepository, @unchecked Sendable {
    
    var fetchedEntries: [Domain.GratitudeEntry] = []
    var savedEntry: Domain.GratitudeEntry?
    
    func fetchEntries() async throws -> [Domain.GratitudeEntry] {
        fetchedEntries
    }
    
    func save(_ entry: Domain.GratitudeEntry) async throws {
        savedEntry = entry
    }
}
