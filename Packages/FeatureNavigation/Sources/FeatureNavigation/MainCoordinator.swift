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
        case start
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
    private let entryRepository: EntryRepository
    private let userProfileRepository: UserRepository
    private let syncService: AppSyncService

    /// Manages the internal push stack of the Mindset modal
    public var mindsetPath = NavigationPath()
    /// Manages the internal push stack of the Profile tab
    public var profilePath = NavigationPath()
    /// Manages the internal push stack of the SignInView
    public var signInPath = NavigationPath()
    /// Pushes onboarding / sign-in on top of `StartView` while `rootState == .start`
    public var startPath = NavigationPath()

    public init(
        authStateQuery: AuthStateQuery,
        subscriptionService: SubscriptionService,
        entryRepository: EntryRepository,
        userRepository: UserRepository,
        syncService: AppSyncService
    ) {
        self.authStateQuery = authStateQuery
        self.subscriptionService = subscriptionService
        self.entryRepository = entryRepository
        self.userProfileRepository = userRepository
        self.syncService = syncService

        // Initial check: Where should we start?
        Task { await evaluateInitialState() }
    }

    public func evaluateInitialState() async {
        // 1. Check if Onboarding is complete FIRST
        let isOboardingComplete: Bool = await userProfileRepository.isOnboardingComplete()

        if !isOboardingComplete {
            if authStateQuery.isAuthenticated() {
                showOnboarding()
            } else {
                showStart()
            }
            return
        }

        // 2. Auth Check
        let isAnonymousAccountLinked = await authStateQuery.isAnonymousAccountLinked()
        if !isAnonymousAccountLinked {
            showAuth()
            return
        }

        // --- SYNC POINT A: Initial Launch ---
        // We don't 'await' this because we want the UI to load mainTabView immediately.
        Task { await syncService.syncAllData() }

        // 3. Setup UI
        refreshProfileTabTitle()
        showDashboard()

        // 4. Paywall Check
        let isPro = await subscriptionService.checkSubscriptionStatus()
        if !isPro {
            set(fullScreenState: .paywall)
        }
    }

    // Navigation Actions

    public func signInCompleted() {
        // User just successfully logged in or linked their account.
        Task { await syncService.syncAllData() }

        refreshProfileTabTitle()
        showDashboard()
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
                showDashboard()
            } else {
                showAuth()
            }
        }
    }

    public func showAuth() {
        clearStartPath()
        set(rootState: .auth)
    }

    public func showStart() {
        clearStartPath()
        set(rootState: .start)
    }

    public func showOnboarding() {
        clearStartPath()
        set(rootState: .onboarding)
    }

    public func showDashboard() {
        clearStartPath()
        set(tab: .dashboard)
        set(rootState: .mainTabView)
    }

    public func showMainTabView() {
        clearStartPath()
        set(fullScreenState: nil)
        refreshProfileTabTitle()
        set(rootState: .mainTabView)
    }

    public func subscriptionPurchased() {
        clearStartPath()
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
        showStart()
        profileTabTitle = ""
        resetNavigationStacks()
    }

    private func resetNavigationStacks() {
        profilePath = NavigationPath()
        signInPath = NavigationPath()
        mindsetPath = NavigationPath()
        clearStartPath()
    }

    private func clearStartPath() {
        startPath = NavigationPath()
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
