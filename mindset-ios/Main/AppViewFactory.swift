//
//  AppViewFactory.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/11/26.
//

import SwiftUI
import Domain
import FeatureOnboarding
import FeatureSubscription
import FeatureDashboard
import FeatureMindset
import FeatureNavigation

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
                coordinator.showDashboard()
            })
        
        return AnyView(
            OnboardingView(viewModel: viewModel)
        )
    }

    func makePaywallView() -> AnyView {
        let viewModel = PaywallViewModel(
            subscriptionService: subscriptionService,
            onPurchaseFinished: {
                coordinator.showDashboard()
            })
        
        return AnyView(
            PaywallView(viewModel: viewModel)
        )
    }

    func makeDashboardView() -> AnyView {
        let viewModel = DashboardViewModel(
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreakUseCase,
            onStartMindet: {
                coordinator.startMorningMindset()
            })
        
        return AnyView(
            DashboardView(viewModel: viewModel)
        )
    }

    func makeMindsetView() -> AnyView {
        let viewModel = MorningRitualViewModel(
            userRepository: userRepository,
            addMindsetUseCase: addMindsetUseCase,
            getYesterdayBridgeUseCase: getYesterdayBridgeUseCase,
            subscriptionService: subscriptionService,
            onComplete: {
                coordinator.showDashboard()
            })

        return AnyView(
            MorningRitualView(viewModel: viewModel)
        )
    }
}
