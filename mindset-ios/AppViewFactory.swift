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
        AnyView(OnboardingView(onComplete: { coordinator.onboardingFinished() }))
    }

    func makePaywallView() -> AnyView {
        AnyView(PaywallView(onPurchase: { coordinator.subscriptionPurchased() }))
    }

    func makeDashboardView() -> AnyView {
        AnyView(DashboardView(
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreakUseCase,
            onStartRitual: {
                coordinator.startMorningMindset()
            }
        ))
    }

    func makeMindsetView() -> AnyView {
        let viewModel = MorningRitualViewModel(
            addMindsetUseCase: addMindsetUseCase,
            getYesterdayBridgeUseCase: getYesterdayBridgeUseCase,
            subscriptionService: subscriptionService) {
                coordinator.showDashboard()
            }
        // Set the completion closure on the VM or View
        return AnyView(MorningRitualView(viewModel: viewModel))
    }
}
