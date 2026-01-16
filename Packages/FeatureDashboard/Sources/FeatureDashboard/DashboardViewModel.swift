//
//  DashboardViewModel.swift
//  FeatureDashboard
//
//  Created by patrick ridd on 1/9/26.
//

import Foundation
import Domain
import Observation

@Observable
@MainActor
public final class DashboardViewModel {
    private let userRepository: UserRepository // For the Name/Goal
    private let mindsetRepository: MindsetRepository // For the Streak/History
    private let getStreakUseCase: GetStreakUseCase
    
    public var userProfile: UserProfile?
    public var recentEntries: [MindsetEntry] = []
    public var isLoading = false
    public var streakCount = 5
    public var latestEntry: MindsetEntry?
    public var currentArchetype = "The Architect"

    // Navigation Actions
    public var onStartMindet: () -> Void

    public init(
        userRepository: UserRepository,
        mindsetRepository: MindsetRepository,
        getStreakUseCase: GetStreakUseCase,
        onStartMindet: @escaping () -> Void
    ) {
        self.userRepository = userRepository
        self.mindsetRepository = mindsetRepository
        self.getStreakUseCase = getStreakUseCase
        self.onStartMindet = onStartMindet
    }

    public func loadDashboardData() async {
        isLoading = true
        do {
            // Fetch the identity we saved during onboarding
            self.userProfile = try await userRepository.fetchUserProfile()
            self.latestEntry = try await mindsetRepository.fetchLatestEntry()
            self.streakCount = try await getStreakUseCase.execute()
        } catch {
            print("Dashboard load failed: \(error)")
        }
        isLoading = false
    }
}
