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
            .refreshable {
                await viewModel.pulledToRefresh()
            }
        }
    }

    private func historyRow(for entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            HStack {
                Text(entry.dateCreated.formatted(date: .abbreviated, time: .omitted))
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

            // First response may be a multi-slot answer with no reflection; use first non-nil.
            if let firstReflection = entry.promptResponses.compactMap(\.aiReflection).first {
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
    let mockEntryRepo = MockEntryRepository(days: 2)
    let syncService = AppSyncService(userLocal: MockUserRepository(), userRemote: MockUserRepository(), entryLocal: mockEntryRepo, entryRemote: mockEntryRepo, authService: MockAuthService(), logger: DebugLogger.shared)
    let viewModel = MindsetHistoryViewModel(entryRepository: mockEntryRepo, syncService: syncService, logger: DebugLogger.shared)
    MindsetHistoryView(viewModel: viewModel)
}
