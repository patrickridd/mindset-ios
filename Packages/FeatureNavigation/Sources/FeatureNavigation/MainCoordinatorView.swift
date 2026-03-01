//
//  MainCoordinatorView.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/7/26.
//

import Domain
import SharedUI
import SwiftUI

public protocol MainViewFactory {
    func makeSignInView() -> AnyView
    func makeOnboardingView() -> AnyView
    func makePaywallView() -> AnyView
    func makeHomeView() -> AnyView
    func makeMindsetView() -> AnyView
    func makeRitualSuccessView(archetype: String, xp: Int) -> AnyView
    func makeLoadingView() -> AnyView
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
            case .auth: factory.makeSignInView()
            case .onboarding: factory.makeOnboardingView()
            case .home: factory.makeHomeView()
            case .loading: factory.makeLoadingView()
            }
        }
        // Full Screen Cover Layer (paywall, mindset ritual, ritualSuccess)
        .mindsetFullScreenCover(item: $coordinator.fullScreenState) { state in
            switch state {
            case .paywall:
                factory.makePaywallView()
            case .mindset:
                factory.makeMindsetView()
            case .ritualSuccess(let archetype, let xp):
                factory.makeRitualSuccessView(archetype: archetype, xp: xp)
            }
        }
        // Sheet Layer (for other modals)
        .mindsetSheet(item: $coordinator.sheetState) { state in
            switch state {
            case .ritualSuccess(let archetype, let xp):
                factory.makeRitualSuccessView(archetype: archetype, xp: xp)
            }
        }
        .animation(.default, value: coordinator.rootState)
    }
}
