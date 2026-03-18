//
//  MainCoordinator.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/7/26.
//

import Domain
import SwiftUI

@Observable
public final class MainCoordinator {

    // Exclusive primary screens
    public enum RootState {
        case auth
        case onboarding
        case mainTabView
        case loading
    }

    // Modals and Overlays (Identifiable for SwiftUI item-based presentation)
    /// Mindset is a full-screen overlay so MainTabView stays alive—avoids Dashboard reload on dismiss.
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
    public private(set) var profileTabTitle: String = ""

    private let authStateQuery: AuthStateQuery
    private let subscriptionService: SubscriptionService
    private let mindsetRepository: MindsetRepository
    private let userProfileRepository: UserRepository
    /// Manages the internal push stack of the Mindset modal
    public var mindsetPath = NavigationPath()
    /// Manages the internal push stack of the Profile tab
    public var profilePath = NavigationPath()
    /// Manages the internal push stack of the SignInView
    public var signInPath = NavigationPath()

    public init(
        authStateQuery: AuthStateQuery,
        subscriptionService: SubscriptionService,
        mindsetRepository: MindsetRepository,
        userRepository: UserRepository
    ) {
        self.authStateQuery = authStateQuery
        self.subscriptionService = subscriptionService
        self.mindsetRepository = mindsetRepository
        self.userProfileRepository = userRepository

        // Initial check: Where should we start?
        Task { await evaluateInitialState() }
    }

    public func evaluateInitialState() async {
        // Quiz First, Auth Last Strategy (Duolingo-style)

        // 1. Check if Onboarding is complete FIRST
        let isOboardingComplete: Bool = await userProfileRepository.isOnboardingComplete()

        if !isOboardingComplete {
            // Show onboarding (quiz + content) regardless of auth status
            set(rootState: .onboarding)
            return
        }

        // 2. Check if user's anonymous account has been linked
        let isAuthenticated = await authStateQuery.isAuthenticated()
        let isAnonymousAccountLinked = await authStateQuery.isAnonymousAccountLinked()
        if !isAnonymousAccountLinked {
            // Onboarding complete but not signed in yet → show auth
            set(rootState: .auth)
            return
        }

        // 3. User is authenticated and onboarding complete → show mainTabView
        refreshProfileTabTitle()
        set(rootState: .mainTabView)

        // 4. Check subscription status and show paywall if needed
        let isPro = await subscriptionService.checkSubscriptionStatus()

        if !isPro {
            set(fullScreenState: .paywall)
        }
    }

    // Navigation Actions

    public func signInCompleted() {
        refreshProfileTabTitle()
        set(tab: .dashboard)
        set(rootState: .mainTabView)
        Task {
            let isPro = await subscriptionService.checkSubscriptionStatus()
            if !isPro {
                set(fullScreenState: .paywall)
            }
        }
    }

    public func onboardingFinished() {
        Task {
            let isAuthenticated = await authStateQuery.isAuthenticated()

            if isAuthenticated {
                refreshProfileTabTitle()
                set(rootState: .mainTabView)
            } else {
                set(rootState: .auth)
            }
        }
    }

    public func showAuth() {
        set(rootState: .auth)
    }

    public func showMainTabView() {
        set(fullScreenState: nil)
        refreshProfileTabTitle()
        set(rootState: .mainTabView)
    }

    public func subscriptionPurchased() {
        set(rootState: .mainTabView)
    }

    public func startMorningMindset() {
        mindsetPath = NavigationPath()  // Reset the path
        set(rootState: .mainTabView)
        set(fullScreenState: .mindset)
    }

    public func set(tab: Tab) {
        withAnimation { selectedTab = tab }
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
        profileTabTitle = ""
        resetNavigationStacks()
    }

    public func accountDeleted() {
        set(rootState: .auth)
        set(tab: .dashboard)
        profileTabTitle = ""
        resetNavigationStacks()
    }

    private func resetNavigationStacks() {
        profilePath = NavigationPath()
        signInPath = NavigationPath()
        mindsetPath = NavigationPath()
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

    public func refreshProfileTabTitle() {
        Task { @MainActor [userProfileRepository] in
            let userName = (try? await userProfileRepository.fetchUserProfile()?.userName) ?? ""
            let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
            profileTabTitle = trimmed
        }
    }
}
