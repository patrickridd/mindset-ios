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

    @State private var viewModel: DashboardViewModel

        public init(viewModel: DashboardViewModel) {
            // Initialize the ViewModel with the injected service
            self._viewModel = State(initialValue: viewModel)
        }

        public var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        if viewModel.isLoading {
                            ProgressView().padding()
                        } else {
                            headerSection
                            identityCard
                            if let yesterday = viewModel.yesterdayGoal {
                                yesterdayBridge(text: yesterday)
                            }
                            statsGrid
                            
                            Spacer(minLength: 40)
                            
                            Button(action: viewModel.startMindsetButtonTapped) {
                                HStack {
                                    Text("Begin Morning Ritual")
                                    Image(systemName: "sparkles")
                                }
                                .font(MindsetFonts.button)
                                .foregroundStyle(MindsetColors.textOnAccent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Capsule().fill(MindsetColors.accentOrange))
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .background(MindsetColors.backgroundGrouped)
                .navigationTitle("Mindset")
                .task {
                    await viewModel.loadDashboardData()
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
                    .foregroundStyle(MindsetColors.textSecondaryAdaptive)
                // Use the data from Onboarding!
                Text(viewModel.userProfile?.userName ?? "Visionary")
                    .font(MindsetFonts.screenTitle)
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive)
            }
        }
        
        private var identityCard: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text("CURRENT GOAL")
                    .font(MindsetFonts.labelUppercase)
                    .tracking(1)
                    .foregroundStyle(MindsetColors.textSecondary)
                
                Text(viewModel.userProfile?.primaryGoal ?? "Calibrate Your Mindset")
                    .font(MindsetFonts.promptHeadline)
                    .foregroundStyle(MindsetColors.textPrimary)
            }
            .padding(25)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [MindsetColors.accentCoral, MindsetColors.accentOrange], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
        }
    
    private func yesterdayBridge(text: String) -> some View {
        VStack(alignment: .leading) {
            Text("YESTERDAY'S FOCUS").font(MindsetFonts.labelUppercase).foregroundStyle(MindsetColors.accentOrange)
            Text(text).font(MindsetFonts.subheadline).italic().foregroundStyle(MindsetColors.textPrimaryAdaptive).lineLimit(nil)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Capsule().stroke(MindsetColors.stoicSlateSoft))
    }
    
    private var statsGrid: some View {
        HStack(spacing: 15) {
            statBox(
                title: "Streak",
                value: "\(viewModel.streakCount) Days",
                icon: "flame.fill",
                // Only light up the flame if they have an active streak
                color: viewModel.streakCount > 0 ? MindsetColors.accentOrange : MindsetColors.textSecondaryAdaptive
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
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(MindsetFonts.statValue).foregroundStyle(MindsetColors.textPrimaryAdaptive)
            Text(title).font(MindsetFonts.caption).foregroundStyle(MindsetColors.textSecondaryAdaptive)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(MindsetColors.backgroundSecondary)
        .cornerRadius(16)
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
