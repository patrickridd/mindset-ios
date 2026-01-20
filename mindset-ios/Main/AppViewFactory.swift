//
//  AppViewFactory.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/11/26.
//

import SwiftUI
import Data
import Domain
import FeatureOnboarding
import FeatureSubscription
import FeatureDashboard
import FeatureMindset
import FeatureNavigation
import FeatureHistory

struct AppViewFactory: MainViewFactory {
    let coordinator: MainCoordinator
    let userRepository: UserRepository
    let mindsetRepository: MindsetRepository
    let getStreakUseCase: GetStreakUseCase
    let addMindsetUseCase: AddMindsetUseCase
    let getYesterdayBridgeUseCase: GetYesterdayBridgeUseCase
    let subscriptionService: SubscriptionService
    
    func makeOnboardingView() -> AnyView {
        let viewModel = OnboardingViewModel(
            userRepository: userRepository,
            onboardingFinished: {
                coordinator.showHomeView()
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
                coordinator.dismissSheet()
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
            onStartMindet: {
                coordinator.startMorningMindset()
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
            getYesterdayBridgeUseCase: getYesterdayBridgeUseCase,
            subscriptionService: subscriptionService,
            aiService: aiService,
            onNavigate: { state in
                switch state {
                case .success(let archetype, let xp):
                    coordinator.showRitualSuccess(archetype: archetype, xp: xp)
                case .paywall:
                    coordinator.showPaywall()
                }
            })

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
