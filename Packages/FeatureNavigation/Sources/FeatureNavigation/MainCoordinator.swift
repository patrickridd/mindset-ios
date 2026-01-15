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
    private(set) var currentState: AppState = .onboarding
    
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
            set(currentState: .onboarding)
            return
        }
        
        // 2. Check Subscription
        let isPro = await subscriptionService.checkSubscriptionStatus()
        if !isPro {
            set(currentState: .paywall)
        } else {
            set(currentState: .dashboard)
        }
    }
    
    // Navigation Actions

    public func onboardingFinished() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        set(currentState: .paywall)
    }

    public func showDashboard() {
        set(currentState: .dashboard)
    }

    public func subscriptionPurchased() {
        set(currentState: .dashboard)
    }

    public func startMorningMindset() {
        set(currentState: .mindset)
    }

    public func showPaywall() {
        set(currentState: .paywall)
    }

    public func showRitualSuccess() {
        set(currentState: .ritualSuccess)
    }
    
    private func set(currentState: AppState) {
        withAnimation { self.currentState = currentState }
    }
}
