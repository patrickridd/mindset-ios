//
//  MainCoordinator.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/7/26.
//


import SwiftUI
import Domain

@Observable
@MainActor
public final class MainCoordinator {
    public var currentState: AppState = .onboarding
    
    private let subscriptionService: SubscriptionService
    private let mindsetRepository: MindsetRepository
    private let userProfileRepository: UserRepository

    public init(subscriptionService: SubscriptionService, mindsetRepository: MindsetRepository, userRepository: UserRepository) {
        self.subscriptionService = subscriptionService
        self.mindsetRepository = mindsetRepository
        self.userProfileRepository = userRepository
        
        // Initial check: Where should we start?
        Task { await evaluateInitialState() }
    }

    public func evaluateInitialState() async {
        // 1. Check if Onboarding is complete (usually from UserDefaults/Supabase)
        let isFirstRun = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if isFirstRun {
            currentState = .onboarding
            return
        }
        
        // 2. Check Subscription
        let isPro = await subscriptionService.checkSubscriptionStatus()
        if !isPro {
            currentState = .paywall
        } else {
            currentState = .dashboard
        }
    }
    
    // Navigation Actions
    @MainActor
    public func onboardingFinished() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation { currentState = .paywall }
    }
    
    @MainActor
    public func subscriptionPurchased() {
        withAnimation { currentState = .dashboard }
    }
}
