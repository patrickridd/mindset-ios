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
    func makeTabView() -> AnyView
    func makeDashboardView() -> AnyView
    func makeMindsetHistoryView() -> AnyView
    func makeUserProfileView() -> AnyView
    func makeMindsetRitualView() -> AnyView
    func makeRitualSuccessView(archetype: String, xp: Int) -> AnyView
    func makeLoadingView() -> AnyView

    /// Apply cross-cutting presentation concerns (e.g., debug wrappers) from the composition root.
    /// Feature modules should not use build-configuration macros.
    func decoratePresentedView(_ view: AnyView) -> AnyView
}

public extension MainViewFactory {
    func decoratePresentedView(_ view: AnyView) -> AnyView { view }
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
            case .auth: factory.decoratePresentedView(factory.makeSignInView())
            case .onboarding: factory.decoratePresentedView(factory.makeOnboardingView())
            case .home: factory.decoratePresentedView(factory.makeTabView())
            case .loading: factory.decoratePresentedView(factory.makeLoadingView())
            }
        }
        // Full Screen Cover Layer (paywall, mindset ritual, ritualSuccess)
        .mindsetFullScreenCover(item: $coordinator.fullScreenState) { state in
            switch state {
            case .paywall:
                factory.decoratePresentedView(factory.makePaywallView())
            case .mindset:
                factory.decoratePresentedView(factory.makeMindsetRitualView())
            case .ritualSuccess(let archetype, let xp):
                factory.decoratePresentedView(
                    factory.makeRitualSuccessView(archetype: archetype, xp: xp))
            }
        }
        // Sheet Layer (for other modals)
        .mindsetSheet(item: $coordinator.sheetState) { state in
            switch state {
            case .ritualSuccess(let archetype, let xp):
                factory.decoratePresentedView(
                    factory.makeRitualSuccessView(archetype: archetype, xp: xp))
            }
        }
        .animation(.default, value: coordinator.rootState)
    }
}

public extension View {
    func mindsetSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        sheet(item: item, onDismiss: onDismiss) { item in
            content(item)
        }
    }

    func mindsetFullScreenCover<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        fullScreenCover(item: item, onDismiss: onDismiss) { item in
            content(item)
        }
    }
}
