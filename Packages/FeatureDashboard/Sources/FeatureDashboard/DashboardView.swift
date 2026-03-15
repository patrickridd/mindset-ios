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

    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: DashboardViewModel

    public init(viewModel: DashboardViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body Composition

    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                ScrollView {
                    VStack(alignment: .leading, spacing: MindsetLayout.spacing20) {
                        if viewModel.isLoading {
                            loadingView
                        } else {
                            headerSection
                            identityCard
                            if let yesterday = viewModel.yesterdayGoal {
                                yesterdayBridge(text: yesterday)
                            }
                            statsGrid
                            securitySection
                            Spacer(minLength: MindsetLayout.spacing4)
                            beginRitualButton
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, MindsetLayout.spacing16)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(FeatureDashboardStrings.navTitle)
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadDashboardData()
            }
        }
    }
}

// MARK: - Subviews

private extension DashboardView {

    var backgroundView: some View {
        MindsetColors.backgroundGrouped(for: colorScheme)
            .ignoresSafeArea()
    }

    var loadingView: some View {
        ProgressView()
            .padding(MindsetLayout.paddingCard)
    }

    var headerSection: some View {
        VStack(alignment: .leading) {
            Text(FeatureDashboardStrings.Greeting.morningWithComma)
                .font(MindsetFonts.subheadline)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
            Text(viewModel.userProfile?.userName ?? FeatureDashboardStrings.defaultUserName)
                .font(MindsetFonts.screenTitle)
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
        }
    }

    var identityCard: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing15) {
            Text(FeatureDashboardStrings.Goal.currentLabel)
                .font(MindsetFonts.labelUppercase)
                .tracking(1)
                .foregroundStyle(MindsetColors.textSecondaryDark)

            Text(
                viewModel.userProfile?.primaryGoal
                    ?? FeatureDashboardStrings.Goal.defaultPlaceholder
            )
            .font(MindsetFonts.promptHeadline)
            .foregroundStyle(MindsetColors.textPrimaryDark)
        }
        .padding(MindsetLayout.paddingCard)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: MindsetLayout.radiusIdentityCard)
                .fill(
                    LinearGradient(
                        colors: [MindsetColors.accentCoral, MindsetColors.accentOrange],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }

    func yesterdayBridge(text: String) -> some View {
        VStack(alignment: .leading) {
            Text(FeatureDashboardStrings.Yesterday.label)
                .font(MindsetFonts.labelUppercase)
                .foregroundStyle(MindsetColors.accentOrange)
            Text(text)
                .font(MindsetFonts.subheadline)
                .italic()
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                .lineLimit(nil)
        }
        .padding(MindsetLayout.paddingCard)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Capsule()
                .fill(MindsetColors.backgroundSecondary(for: colorScheme))
        )
    }

    var statsGrid: some View {
        HStack(spacing: MindsetLayout.spacing15) {
            statBox(
                title: FeatureDashboardStrings.Streak.statLabel,
                value: String(format: FeatureDashboardStrings.Streak.days, viewModel.streakCount),
                icon: "flame.fill",
                color: viewModel.streakCount > 0
                    ? MindsetColors.accentOrange
                    : MindsetColors.textSecondaryAdaptive(for: colorScheme)
            )

            statBox(
                title: FeatureDashboardStrings.Rituals.statLabel,
                value: String(
                    format: FeatureDashboardStrings.Rituals.totalFormat, viewModel.totalRituals),
                icon: "checkmark.circle.fill",
                color: MindsetColors.successGreen
            )
            .onTapGesture {
                viewModel.seeHistoryBoxTapped()
            }
        }
    }

    var beginRitualButton: some View {
        Button(action: {
            HapticManager.action()
            viewModel.startMindsetButtonTapped()
        }) {
            HStack {
                Text(FeatureDashboardStrings.CTA.beginMorningRitual)
                Image(systemName: "sparkles")
            }
            .font(MindsetFonts.button)
            .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
            .frame(maxWidth: .infinity)
            .frame(height: MindsetLayout.buttonHeight)
            .background(Capsule().fill(MindsetColors.accentOrange))
        }
        .padding(.horizontal, MindsetLayout.paddingStandard)
    }

    func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing10) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(MindsetFonts.statValue)
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
            Text(title)
                .font(MindsetFonts.caption)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MindsetLayout.paddingStandard)
        .background(MindsetColors.backgroundSecondary(for: colorScheme))
        .cornerRadius(MindsetLayout.radiusCard)
    }
    
    @ViewBuilder
    var securitySection: some View {
        if let user = viewModel.userProfile {
            if !user.isAccountSecured && viewModel.streakCount > 0 {
                AccountSecurityCallout(
                    streakCount: viewModel.streakCount,
                    onLinkAction: {
                        viewModel.secureAccountButtonTapped()
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    let mindsetRepository = MockMindsetRepository(days: 1)
    let viewModel = DashboardViewModel(
        userRepository: MockUserRepository(),
        mindsetRepository: mindsetRepository,
        getStreakUseCase: GetStreakUseCase(repository: mindsetRepository),
        getYesterdayGoalUseCase: GetYesterdayGoalUseCase(repository: mindsetRepository),
        logger: DebugLogger.shared,
        onStartMindset: {},
        onSeeHistory: {},
        onSecureAccount: {}
    )
    DashboardView(viewModel: viewModel)
}
