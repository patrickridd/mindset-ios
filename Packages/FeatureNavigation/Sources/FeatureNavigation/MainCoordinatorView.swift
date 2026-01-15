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
        NavigationStack {
            VStack {
                switch coordinator.currentState {
                case .onboarding:
                    factory.makeOnboardingView()
                case .dashboard:
                    factory.makeDashboardView()
                case .mindset:
                    factory.makeMindsetView()
                default:
                    EmptyView()
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: {
                    if case .ritualSuccess = coordinator.currentState { return true }
                    return false
                },
                set: { _ in }
            )) {
                if case .ritualSuccess(let archetype, let xp) = coordinator.currentState {
                    factory.makeRitualSuccessView(archetype: archetype, xp: xp)
                }
            }
            .sheet(isPresented: Binding(get: { coordinator.currentState == .paywall}, set: { _ in })) {
                factory.makePaywallView()
            }
        }
        .animation(.default, value: coordinator.currentState)
    }
}
