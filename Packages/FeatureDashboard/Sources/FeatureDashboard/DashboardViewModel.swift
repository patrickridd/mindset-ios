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
    // Dependencies
    private let userRepository: UserRepository
    private let mindsetRepository: MindsetRepository
    private let getStreakUseCase: GetStreakUseCase
    
    // UI State
    public var userProfile: UserProfile?
    public var recentEntries: [MindsetEntry] = []
    public var isLoading = false
    public var streakCount: Int = 0 // Initialized to 0, fetched from UseCase
    public var totalRituals: Int = 0 // New property for the stats grid
    public var latestEntry: MindsetEntry?
    
    // Dynamic Archetype based on the most recent ritual
    public var currentArchetype: String {
        latestEntry?.archetypeTag ?? "The Visionary"
    }

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
        // Prevent flashing if data is already there, or keep it true for a hard refresh
        isLoading = true
        
        do {
            // 1. Fetch User Identity (Name and Primary Goal)
            self.userProfile = try await userRepository.fetchUserProfile()
            
            // 2. Fetch all entries to calculate totals and recent history
            let allEntries = try await mindsetRepository.fetchAllEntries()
            self.recentEntries = Array(allEntries.prefix(3)) // Get last 3 for a "Recent" list
            self.totalRituals = allEntries.count
            
            // 3. Set the latest entry for the Archetype display
            self.latestEntry = allEntries.first
            
            // 4. Calculate the current streak using our dedicated UseCase
            // This handles the "today vs yesterday" logic automatically
            self.streakCount = try await getStreakUseCase.execute()
            
        } catch {
            print("Dashboard load failed: \(error)")
            // Fallback: If fetch fails, we keep existing values or set defaults
        }
        
        isLoading = false
    }
}
