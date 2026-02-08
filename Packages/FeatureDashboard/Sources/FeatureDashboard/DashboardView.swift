//
//  DashboardView.swift
//  FeatureDashboard
//
//  Created by patrick ridd on 1/7/26.
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

public struct DashboardView: View {
    
#if DEBUG
    @ObserveInjection var inject
#endif
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: DashboardViewModel
    
    public init(viewModel: DashboardViewModel) {
        // Initialize the ViewModel with the injected service
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                MindsetColors.backgroundGrouped(for: colorScheme)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: MindsetLayout.spacing25) {
                        if viewModel.isLoading {
                            ProgressView().padding()
                        } else {
                            headerSection
                            identityCard
                            if let yesterday = viewModel.yesterdayGoal {
                                yesterdayBridge(text: yesterday)
                            }
                            statsGrid
                            
                            Spacer(minLength: MindsetLayout.spacerMinLength)
                            
                            Button(action: {
                                HapticManager.action()
                                viewModel.startMindsetButtonTapped()
                            }) {
                                HStack {
                                    Text("Begin Morning Ritual")
                                    Image(systemName: "sparkles")
                                }
                                .font(MindsetFonts.button)
                                .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                                .frame(maxWidth: .infinity)
                                .frame(height: MindsetLayout.buttonHeight)
                                .background(Capsule().fill(MindsetColors.accentOrange))
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Mindset")
                .toolbarBackground(MindsetColors.backgroundGrouped(for: colorScheme), for: .navigationBar)
                .scrollContentBackground(.hidden)
                .task {
                    await viewModel.loadDashboardData()
                }
            }
        }
#if DEBUG
        .enableInjection()
#endif
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading) {
            Text("Good Morning,")
                .font(MindsetFonts.subheadline)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
            // Use the data from Onboarding!
            Text(viewModel.userProfile?.userName ?? "Visionary")
                .font(MindsetFonts.screenTitle)
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
        }
    }
    
    private var identityCard: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing15) {
            Text("CURRENT GOAL")
                .font(MindsetFonts.labelUppercase)
                .tracking(1)
                .foregroundStyle(MindsetColors.textSecondary)
            
            Text(viewModel.userProfile?.primaryGoal ?? "Calibrate Your Mindset")
                .font(MindsetFonts.promptHeadline)
                .foregroundStyle(MindsetColors.textPrimary)
        }
        .padding(MindsetLayout.paddingCard)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: MindsetLayout.radiusIdentityCard)
                .fill(LinearGradient(colors: [MindsetColors.accentCoral, MindsetColors.accentOrange], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }
    
    private func yesterdayBridge(text: String) -> some View {
        VStack(alignment: .leading) {
            Text("YESTERDAY'S FOCUS").font(MindsetFonts.labelUppercase).foregroundStyle(MindsetColors.accentOrange)
            Text(text).font(MindsetFonts.subheadline).italic().foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme)).lineLimit(nil)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Capsule().stroke(MindsetColors.stoicSlateSoft))
    }
    
    private var statsGrid: some View {
        HStack(spacing: MindsetLayout.spacing15) {
            statBox(
                title: "Streak",
                value: "\(viewModel.streakCount) Days",
                icon: "flame.fill",
                // Only light up the flame if they have an active streak
                color: viewModel.streakCount > 0 ? MindsetColors.accentOrange : MindsetColors.textSecondaryAdaptive(for: colorScheme)
            )
            
            statBox(
                title: "Rituals",
                // Replace hardcoded "12" with the real count from your repository
                value: "\(viewModel.totalRituals) Total",
                icon: "checkmark.circle.fill",
                color: MindsetColors.successGreen
            ).onTapGesture {
                viewModel.seeHistoryBoxTapped()
            }
        }
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing10) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(MindsetFonts.statValue).foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
            Text(title).font(MindsetFonts.caption).foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(MindsetColors.backgroundSecondary(for: colorScheme))
        .cornerRadius(MindsetLayout.radiusCard)
    }
}

#Preview {
    let mindSetReposoitory = MockMindsetRepository(days: 1)
    let viewModel = DashboardViewModel(
        userRepository: MockUserRepository(),
        mindsetRepository: mindSetReposoitory,
        getStreakUseCase: GetStreakUseCase(repository: mindSetReposoitory),
        getYesterdayGoalUseCase: GetYesterdayGoalUseCase(repository: mindSetReposoitory),
        onStartMindet: {},
        onSeeHistory: {})
    return DashboardView(viewModel: viewModel)
}
