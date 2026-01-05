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
        VStack(spacing: 20) {
            Text("Your Mindset")
                .font(.largeTitle)
                .bold()
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.streakDisplay)
                    .font(.system(size: 60))
            }
            
            Button("Refresh") {
                Task { await viewModel.refreshStreak() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            Task { await viewModel.refreshStreak() }
        }
    }
}

#Preview {
    // Build a simple, non-throwing view model for previews
    let streakUseCase = GetStreakUseCase(repository: GratitudeRepositoryStub())
    let viewModel = GratitudeViewModel(useCase: streakUseCase)
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
