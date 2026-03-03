//
//  MainCoordinator.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/7/26.
//

import Domain
#if DEBUG
import Development
#endif
import SwiftUI

@Observable
@MainActor
public final class MainCoordinator {

    // Exclusive primary screens
    public enum RootState {
        case auth
        case onboarding
        case home
        case loading
    }

    // Modals and Overlays (Identifiable for SwiftUI item-based presentation)
    /// Mindset is a full-screen overlay so home stays alive—avoids Dashboard reload on dismiss.
    public enum FullScreenState: Identifiable {
        case paywall
        case mindset
        case ritualSuccess(archetype: String, xp: Int)

        public var id: String {
            switch self {
            case .paywall: return "paywall"
            case .mindset: return "mindset"
            case .ritualSuccess(let a, let x): return "success-\(a)-\(x)"
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

    private(set) var rootState: RootState = .loading
    public var fullScreenState: FullScreenState?
    public var sheetState: SheetState?
    public var selectedTab: Tab = .dashboard

    private let appDefaults: any AppDefaults
    private let authService: AuthService
    private let subscriptionService: SubscriptionService
    private let mindsetRepository: MindsetRepository
    private let userProfileRepository: UserRepository
    // Manages the internal push stack of the Mindset modal
    public var mindsetPath = NavigationPath()
    // Manages the internal push stack of the Profile tab
    public var profilePath = NavigationPath()

    public init(
        appDefaults: any AppDefaults,
        authService: AuthService,
        subscriptionService: SubscriptionService,
        mindsetRepository: MindsetRepository,
        userRepository: UserRepository
    ) {
        self.appDefaults = appDefaults
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
        #if DEBUG
        let onboardingComplete: Bool
        if DebugSettings.shared.onboardingOverrideEnabled {
            onboardingComplete = DebugSettings.shared.onboardingOverrideValue
        } else {
            onboardingComplete = appDefaults.onboardingComplete
        }
        #else
        let onboardingComplete = appDefaults.onboardingComplete
        #endif

        if !onboardingComplete {
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
        // Step 12 complete → transition to home, then show Paywall (step 13) if not already Pro
        set(rootState: .home)
        Task {
            let isPro = await subscriptionService.checkSubscriptionStatus()
            if !isPro {
                set(fullScreenState: .paywall)
            }
        }
    }

    public func onboardingFinished() {
        // Steps 1-11 complete → now show Auth (step 12)
        appDefaults.onboardingComplete = true
        Task {
            let isAuthenticated = await authService.isAuthenticated()

            if !isAuthenticated {
                set(rootState: .auth)
                return
            } else {
                set(rootState: .home)
            }
        }
    }

    public func showHomeView() {
        set(fullScreenState: nil)
        set(rootState: .home)
    }

    public func subscriptionPurchased() {
        set(rootState: .home)
    }

    public func startMorningMindset() {
        mindsetPath = NavigationPath()  // Reset the path
        set(rootState: .home)
        set(fullScreenState: .mindset)
    }

    public func set(tab: Tab) {
        selectedTab = tab
    }

    public func showPaywall() {
        set(fullScreenState: .paywall)
    }

    public func showRitualSuccess(archetype: String, xp: Int) {
        // Instead of changing fullScreenState (which triggers a new modal),
        // we push a data object into the path.
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            mindsetPath.append(RitualResult(archetype: archetype, xp: xp))
        }
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
