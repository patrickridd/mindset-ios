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
        case profile
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
        // Quiz First, Auth Last Strategy (Duolingo-style)
        
        // 1. Check if Onboarding is complete FIRST
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if !hasCompletedOnboarding {
            // Show onboarding (quiz + content) regardless of auth status
            set(rootState: .onboarding)
            return
        }
        
        // 2. Check if user is authenticated
        let isAuthenticated = await authService.isAuthenticated()
        
        if !isAuthenticated {
            // Onboarding complete but not signed in yet → show auth
            set(rootState: .auth)
            return
        }
        
        // 3. User is authenticated and onboarding complete → show home
        set(rootState: .home)

        // 4. Check subscription status and show paywall if needed
        let isPro = await subscriptionService.checkSubscriptionStatus()

        if !isPro {
            set(fullScreenState: .paywall)
        }
    }
    
    // Navigation Actions
    
    public func signInCompleted() {
        // Step 12 complete → transition to home, then show Paywall (step 13)
        set(rootState: .home)
        set(fullScreenState: .paywall)
    }

    public func onboardingFinished() {
        // Steps 1-11 complete → now show Auth (step 12)
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        set(rootState: .auth)
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
    
    public func signOutCompleted() {
        // Reset to auth screen
        set(rootState: .auth)
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
