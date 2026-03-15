//
//  DashboardViewModel.swift
//  FeatureDashboard
//
//  Created by patrick ridd on 1/9/26.
//

import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class DashboardViewModel {
    // Dependencies
    private let userRepository: UserRepository
    private let mindsetRepository: MindsetRepository
    private let getStreakUseCase: GetStreakUseCase
    private let getYesterdayGoalUseCase: GetYesterdayGoalUseCase
    private let logger: AppLogger

    // UI State
    public var userProfile: UserProfile?
    public var yesterdayGoal: String?
    public var recentEntries: [MindsetEntry] = []
    public var isLoading = false
    public var streakCount: Int = 0  // Initialized to 0, fetched from UseCase
    public var totalRituals: Int = 0  // New property for the stats grid
    public var latestEntry: MindsetEntry?

    // Dynamic Archetype based on the most recent ritual
    public var currentArchetype: String {
        latestEntry?.archetypeTag ?? "The Visionary"
    }

    // Navigation Actions
    private let onStartMindset: () -> Void
    private let onSeeHistory: () -> Void
    private let onSecureAccount: () -> Void

    public init(
        userRepository: UserRepository,
        mindsetRepository: MindsetRepository,
        getStreakUseCase: GetStreakUseCase,
        getYesterdayGoalUseCase: GetYesterdayGoalUseCase,
        logger: AppLogger,
        onStartMindset: @escaping () -> Void,
        onSeeHistory: @escaping () -> Void,
        onSecureAccount: @escaping () -> Void
    ) {
        self.userRepository = userRepository
        self.mindsetRepository = mindsetRepository
        self.getStreakUseCase = getStreakUseCase
        self.getYesterdayGoalUseCase = getYesterdayGoalUseCase
        self.logger = logger
        self.onStartMindset = onStartMindset
        self.onSeeHistory = onSeeHistory
        self.onSecureAccount = onSecureAccount
    }

    public func loadDashboardData() async {
        // Only show loading when we have no cached data (initial load). When returning to the tab,
        // show existing content and refresh in the background without blocking the UI.
        let hasCachedData = userProfile != nil || totalRituals > 0
        if !hasCachedData {
            isLoading = true
        }

        do {
            // 1. Fetch User Identity (Name and Primary Goal)
            self.userProfile = try await userRepository.fetchUserProfile()

            // 2. Fetch all entries to calculate totals and recent history
            let allEntries = try await mindsetRepository.fetchAllEntries()
            self.recentEntries = Array(allEntries.prefix(3))  // Get last 3 for a "Recent" list
            self.totalRituals = allEntries.count

            // 3. Set the latest entry for the Archetype display
            self.latestEntry = allEntries.first

            // 4. Calculate the current streak using our dedicated UseCase
            // This handles the "today vs yesterday" logic automatically
            self.streakCount = try await getStreakUseCase.execute()

            // 5. Fetch Yesterday Bridge (last goal-oriented response)
            let bridgeResult = try await getYesterdayGoalUseCase.execute()
            self.yesterdayGoal = bridgeResult ?? "Yesterday was a great start. Ready to go again?"

        } catch {
            logger.log("❌ Dashboard load failed: \(error.localizedDescription)")
            // Fallback: If fetch fails, we keep existing values or set defaults
        }

        isLoading = false
    }

    func startMindsetButtonTapped() {
        onStartMindset()
    }

    func seeHistoryBoxTapped() {
        onSeeHistory()
    }

    func secureAccountButtonTapped() {
        onSecureAccount()
    }
}
