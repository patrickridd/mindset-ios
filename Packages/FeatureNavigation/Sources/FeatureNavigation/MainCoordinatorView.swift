//
//  MainCoordinatorView.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI
import Domain

public protocol MainViewFactory {
    func makeOnboardingView() -> AnyView
    func makePaywallView() -> AnyView
    func makeDashboardView() -> AnyView
    func makeMindsetView() -> AnyView
    func makeRitualSuccessView(archetype: String, xp: Int) -> AnyView
}

public struct MainCoordinatorView: View {
    @Bindable var coordinator: MainCoordinator
    private let factory: MainViewFactory

    public init(coordinator: MainCoordinator, factory: MainViewFactory) {
        self.coordinator = coordinator
        self.factory = factory
    }

    public var body: some View {
        Group {
            switch coordinator.currentState {
            case .onboarding:
                factory.makeOnboardingView()
            case .paywall:
                factory.makePaywallView()
            case .dashboard:
                factory.makeDashboardView()
            case .mindset:
                factory.makeMindsetView()
            case .ritualSuccess(let archeType, let xp):
                factory.makeRitualSuccessView(archetype: archeType, xp: xp)
            }
        }
        .animation(.default, value: coordinator.currentState)
    }
}
