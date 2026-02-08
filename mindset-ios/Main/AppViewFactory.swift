//
//  AppViewFactory.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/11/26.
//

import SwiftUI
import Data
import Domain
import SharedUtils
import FeatureAuth
import FeatureOnboarding
import FeatureSubscription
import FeatureDashboard
import FeatureMindset
import FeatureNavigation
import FeatureHistory
import FeatureUserProfile

struct AppViewFactory: MainViewFactory {
    let coordinator: MainCoordinator
    let authService: AuthService
    let userRepository: UserRepository
    let mindsetRepository: MindsetRepository
    let getStreakUseCase: GetStreakUseCase
    let addMindsetUseCase: AddMindsetUseCase
    let getYesterdayGoalUseCase: GetYesterdayGoalUseCase
    let subscriptionService: SubscriptionService
    let serviceFactory: ServiceFactory
    
    func makeSignInView() -> AnyView {
        let viewModel = SignInViewModel(
            authService: authService,
            onSignInSuccess: { userID in
                DebugLogger.shared.add("✅ User signed in: \(userID)")
                coordinator.signInCompleted()
            },
            onSkip: {
                DebugLogger.shared.add("⏭️ User skipped sign in (anonymous)")
                coordinator.signInCompleted()
            }
        )
        
        return AnyView(
            SignInView(viewModel: viewModel)
        )
    }
    
    func makeOnboardingView() -> AnyView {
        let viewModel = OnboardingViewModel(
            userRepository: userRepository,
            onboardingFinished: {
                // Let MainCoordinator handle Auth → Paywall → Home flow
                coordinator.onboardingFinished()
            })
        
        return AnyView(
            OnboardingView(viewModel: viewModel)
        )
    }

    func makePaywallView() -> AnyView {
        let viewModel = PaywallViewModel(
            subscriptionService: subscriptionService,
            onPurchaseFinished: {
                // Dismiss paywall overlay - already at .home root state
                coordinator.dismissFullScreen()
            })
        return AnyView(
            PaywallView(viewModel: viewModel)
        )
    }

    func makeHomeView() -> AnyView {
        let dashboardViewModel = DashboardViewModel(
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreakUseCase,
            getYesterdayGoalUseCase: getYesterdayGoalUseCase,
            onStartMindset: {
                coordinator.startMorningMindset()
            }, onSeeHistory: {
                coordinator.set(tab: .history)
            })
        
        let historyViewModel = MindsetHistoryViewModel(repository: mindsetRepository)
        
        let profileViewModel = UserProfileViewModel(
            authService: authService,
            userRepository: userRepository,
            onSignOut: {
                coordinator.signOutCompleted()
            }
        )

        return AnyView(MainTabView(
            coordinator: coordinator,
            dashboardView: AnyView(DashboardView(viewModel: dashboardViewModel)),
            historyView: AnyView(MindsetHistoryView(viewModel: historyViewModel)),
            profileView: AnyView(UserProfileView(viewModel: profileViewModel)))
        )
    }

    func makeMindsetView() -> AnyView {
        let aiService = serviceFactory.makeAIService()
        let viewModel = MorningRitualViewModel(
            userRepository: userRepository,
            addMindsetUseCase: addMindsetUseCase,
            subscriptionService: subscriptionService,
            aiService: aiService,
            onNavigate: { state in
                switch state {
                case .success(let archetype, let xp):
                    coordinator.showRitualSuccess(archetype: archetype, xp: xp)
                case .paywall:
                    coordinator.showPaywall()
                }
            },
            onDismiss: { coordinator.showHomeView() })

        return AnyView(
            MorningRitualView(viewModel: viewModel)
        )
    }

    func makeRitualSuccessView(archetype: String, xp: Int) -> AnyView {
        AnyView(RitualSuccessView(archetype: archetype, xpEarned: xp) {
            coordinator.showHomeView()
            coordinator.dismissSheet()
        })
    }
}
