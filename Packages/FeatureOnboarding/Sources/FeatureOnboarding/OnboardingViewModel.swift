//
//  OnboardingViewModel.swift
//  FeatureOnboarding
//
//  Created by patrick ridd on 1/9/26.
//

import Foundation
import Domain
import Observation

@Observable
public final class OnboardingViewModel {
    // 1. Dependencies
    private let persistenceService: PersistenceService
    
    // 2. State
    public var onboardingData = OnboardingData()
    public var isCompleting = false
    
    public init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
    @MainActor
    public func finishOnboarding() async {
        isCompleting = true
        
        // 3. Transform OnboardingData into a SwiftData-backed Model
        // We do this so the Dashboard can find it later.
        let profile = UserProfile(
            bestSelfName: onboardingData.bestSelfName,
            primaryGoal: onboardingData.primaryGoal,
            createdAt: .now
        )
        
        // 4. Save to SwiftData (via the PersistenceService)
        do {
            try await persistenceService.saveUserProfile(profile)
            
            // Artificial delay for "Perceived Value" calculation
            try? await Task.sleep(for: .seconds(2)) 
        } catch {
            print("Failed to save onboarding data: \(error)")
        }
        
        isCompleting = false
    }
}
