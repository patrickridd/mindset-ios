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
    
    // Exclusive primary screens
    public enum RootState {
        case onboarding
        case home
        case mindset
    }
    
    // Modals and Overlays (Identifiable for SwiftUI item-based presentation)
    public enum SheetState: Identifiable {
        case paywall
        case ritualSuccess(archetype: String, xp: Int)
        
        public var id: String {
            switch self {
            case .paywall: return "paywall"
            case .ritualSuccess(let a, let x): return "success-\(a)-\(x)"
            }
        }
    }

    public enum Tab {
        case dashboard
        case history
    }

    private(set) var rootState: RootState = .onboarding
    public var sheetState: SheetState?
    public var selectedTab: Tab = .dashboard
    
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
            set(rootState: .onboarding)
            return
        } else {
            set(rootState: .home)
        }

        let isPro = await subscriptionService.checkSubscriptionStatus()

        if !isPro {
            set(sheetState: .paywall)
        }
    }
    
    // Navigation Actions

    public func onboardingFinished() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        set(sheetState: .paywall)
    }

    public func showHomeView() {
        set(rootState: .home)
    }

    public func subscriptionPurchased() {
        set(rootState: .home)
    }

    public func startMorningMindset() {
        set(rootState: .mindset)
    }

    public func set(tab: Tab) {
        selectedTab = tab
    }

    public func showPaywall() {
        set(sheetState: .paywall)
    }

    public func showRitualSuccess(archetype: String, xp: Int) {
        set(sheetState: .ritualSuccess(archetype: archetype, xp: xp))
    }

    public func dismissSheet() {
        set(sheetState: nil)
    }

    private func set(rootState: RootState) {
        withAnimation { self.rootState = rootState }
    }

    private func set(sheetState: SheetState?) {
        withAnimation { self.sheetState = sheetState }
    }
}
