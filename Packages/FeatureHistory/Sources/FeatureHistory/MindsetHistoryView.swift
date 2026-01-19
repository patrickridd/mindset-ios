//
//  MindsetHistoryView.swift
//  FeatureHistory
//
//  Created by patrick ridd on 1/18/26.
//

import Domain
import SwiftUI

public struct MindsetHistoryView: View {
    @State private var viewModel: MindsetHistoryViewModel
    
    public init(viewModel: MindsetHistoryViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.entries.isEmpty {
                    ContentUnavailableView("No Rituals Yet", 
                        systemImage: "book.closed", 
                        description: Text("Complete your first ritual to see your history."))
                } else {
                    List(viewModel.entries, id: \.id) { entry in
                        historyRow(for: entry)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Your Evolution")
            .task { await viewModel.fetchHistory() }
        }
    }
    
    private func historyRow(for entry: MindsetEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.archetypeTag ?? "")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.orange.opacity(0.1)))
                    .foregroundStyle(.orange)
            }
            
            // Show the first AI reflection as a "highlight"
            if let firstReflection = entry.responses.first?.aiReflection {
                Text("\"\(firstReflection)\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MindsetHistoryView(viewModel: MindsetHistoryViewModel(repository: MockMindsetRepository(days: 2)))
}
