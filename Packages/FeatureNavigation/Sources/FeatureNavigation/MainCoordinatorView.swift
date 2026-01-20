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
    func makeHomeView() -> AnyView
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
        ZStack {
            // Root Layer
            switch coordinator.rootState {
            case .onboarding: factory.makeOnboardingView()
            case .home:  factory.makeHomeView()
            case .mindset:    factory.makeMindsetView()
            }
        }
        // Sheet Layer
        .sheet(item: $coordinator.sheetState) { state in
            switch state {
            case .paywall:
                factory.makePaywallView()
            case .ritualSuccess(let archetype, let xp):
                // We use fullScreenCover for this normally,
                // but this is how you'd switch within a sheet
                factory.makeRitualSuccessView(archetype: archetype, xp: xp)
            }
        }
        .animation(.default, value: coordinator.rootState)
    }
}
