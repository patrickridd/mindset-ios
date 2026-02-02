//
//  AppViewFactory.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/11/26.
//

import SwiftUI
import Data
import Domain
import FeatureAuth
import FeatureOnboarding
import FeatureSubscription
import FeatureDashboard
import FeatureMindset
import FeatureNavigation
import FeatureHistory

struct AppViewFactory: MainViewFactory {
    let coordinator: MainCoordinator
    let authService: AuthService
    let userRepository: UserRepository
    let mindsetRepository: MindsetRepository
    let getStreakUseCase: GetStreakUseCase
    let addMindsetUseCase: AddMindsetUseCase
    let getYesterdayGoalUseCase: GetYesterdayGoalUseCase
    let subscriptionService: SubscriptionService
    
    func makeSignInView() -> AnyView {
        let viewModel = SignInViewModel(
            authService: authService,
            onSignInSuccess: { userID in
                print("✅ User signed in: \(userID)")
                coordinator.signInCompleted()
            },
            onSkip: {
                print("⏭️ User skipped sign in (anonymous)")
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
            subscriptionService: subscriptionService,
            onboardingFinished: { state in
                switch state {
                case .home:
                    coordinator.showHomeView()
                case .paywall:
                    coordinator.showPaywall()
                }
            })
        
        return AnyView(
            OnboardingView(viewModel: viewModel)
        )
    }

    func makePaywallView() -> AnyView {
        let viewModel = PaywallViewModel(
            subscriptionService: subscriptionService,
            onPurchaseFinished: {
                coordinator.showHomeView()
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
            onStartMindet: {
                coordinator.startMorningMindset()
            }, onSeeHistory: {
                coordinator.set(tab: .history)
            })
        
        let historyViewModel = MindsetHistoryViewModel(repository: mindsetRepository)

        return AnyView(MainTabView(
            coordinator: coordinator,
            dashboardView: AnyView(DashboardView(viewModel: dashboardViewModel)),
            historyView: AnyView(MindsetHistoryView(viewModel: historyViewModel)))
        )
    }

    func makeMindsetView() -> AnyView {
        let apiKey = AppConfig.geminiAPIKey
        let aiService = GeminiAIService(apiKey: apiKey)
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
