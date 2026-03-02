//
//  MindsetHistoryView.swift
//  FeatureHistory
//
//  Created by patrick ridd on 1/18/26.
//

import Domain
import SharedUI
import SharedUtils
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
                    ContentUnavailableView(
                        "No Rituals Yet",
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
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(MindsetFonts.captionBold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.archetypeTag ?? "")
                    .font(MindsetFonts.label)
                    .padding(.horizontal, MindsetLayout.paddingSmall)
                    .padding(.vertical, MindsetLayout.spacing4)
                    .background(Capsule().fill(MindsetColors.accentOrangeSoft))
                    .foregroundStyle(MindsetColors.accentOrange)
            }

            // Show the first AI reflection as a "highlight"
            if let firstReflection = entry.responses.first?.aiReflection {
                Text("\"\(firstReflection)\"")
                    .font(MindsetFonts.subheadline)
                    .italic()
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, MindsetLayout.paddingSmall)
    }
}

#Preview {
    MindsetHistoryView(
        viewModel: MindsetHistoryViewModel(repository: MockMindsetRepository(days: 2), logger: DebugLogger.shared))
}
