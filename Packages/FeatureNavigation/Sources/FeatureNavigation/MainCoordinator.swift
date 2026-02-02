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
        case auth
        case onboarding
        case home
        case mindset
    }
    
    // Modals and Overlays (Identifiable for SwiftUI item-based presentation)
    public enum FullScreenState: Identifiable {
        case paywall
        
        public var id: String {
            switch self {
            case .paywall: return "paywall"
            }
        }
    }
    
    public enum SheetState: Identifiable {
        case ritualSuccess(archetype: String, xp: Int)
        
        public var id: String {
            switch self {
            case .ritualSuccess(let a, let x): return "success-\(a)-\(x)"
            }
        }
    }

    public enum Tab {
        case dashboard
        case history
    }

    private(set) var rootState: RootState = .onboarding
    public var fullScreenState: FullScreenState?
    public var sheetState: SheetState?
    public var selectedTab: Tab = .dashboard
    
    private let authService: AuthService
    private let subscriptionService: SubscriptionService
    private let mindsetRepository: MindsetRepository
    private let userProfileRepository: UserRepository

    public init(
        authService: AuthService,
        subscriptionService: SubscriptionService,
        mindsetRepository: MindsetRepository,
        userRepository: UserRepository
    ) {
        self.authService = authService
        self.subscriptionService = subscriptionService
        self.mindsetRepository = mindsetRepository
        self.userProfileRepository = userRepository
        
        // Initial check: Where should we start?
        Task { await evaluateInitialState() }
    }

    public func evaluateInitialState() async {
        // 1. Check if user is authenticated
        let isAuthenticated = await authService.isAuthenticated()
        
        if !isAuthenticated {
            set(rootState: .auth)
            return
        }
        
        // 2. Check if Onboarding is complete
        let isFirstRun = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if isFirstRun {
            set(rootState: .onboarding)
            return
        } else {
            set(rootState: .home)
        }

        // 3. Check subscription status
        let isPro = await subscriptionService.checkSubscriptionStatus()

        if !isPro {
            set(fullScreenState: .paywall)
        }
    }
    
    // Navigation Actions
    
    public func signInCompleted() {
        // After sign in, show onboarding
        set(rootState: .onboarding)
    }

    public func onboardingFinished() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        set(fullScreenState: .paywall)
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
        set(fullScreenState: .paywall)
    }

    public func showRitualSuccess(archetype: String, xp: Int) {
        set(sheetState: .ritualSuccess(archetype: archetype, xp: xp))
    }

    public func dismissFullScreen() {
        set(fullScreenState: nil)
    }
    
    public func dismissSheet() {
        set(sheetState: nil)
    }

    private func set(rootState: RootState) {
        withAnimation { self.rootState = rootState }
    }
    
    private func set(fullScreenState: FullScreenState?) {
        withAnimation { self.fullScreenState = fullScreenState }
    }

    private func set(sheetState: SheetState?) {
        withAnimation { self.sheetState = sheetState }
    }
}
