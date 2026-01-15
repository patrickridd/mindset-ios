//
//  MainCoordinatorView.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI
import Domain

// FeatureNavigation
public protocol MainViewFactory {
    func makeOnboardingView() -> AnyView
    func makePaywallView() -> AnyView
    func makeDashboardView() -> AnyView
    func makeMindsetView() -> AnyView
    func makeRitualSuccessView() -> AnyView
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
            case .onboarding: factory.makeOnboardingView()
            case .paywall:    factory.makePaywallView()
            case .dashboard:  factory.makeDashboardView()
            case .mindset:    factory.makeMindsetView()
            case .ritualSuccess: factory.makeRitualSuccessView()
            }
        }
        .animation(.default, value: coordinator.currentState)
    }
}
