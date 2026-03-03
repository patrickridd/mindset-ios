//
//  MainTabView.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/20/26.
//

import SharedLocalization
import SwiftUI

public struct MainTabView: View {
    @Bindable var coordinator: MainCoordinator
    private let dashboardView: AnyView
    private let historyView: AnyView
    private let profileView: AnyView

    public init(
        coordinator: MainCoordinator,
        dashboardView: AnyView,
        historyView: AnyView,
        profileView: AnyView
    ) {
        self.coordinator = coordinator
        self.dashboardView = dashboardView
        self.historyView = historyView
        self.profileView = profileView
    }

    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            dashboardView
                .tabItem {
                    Label {
                        Text(FeatureNavigationStrings.Tab.today)
                    } icon: {
                        Image(systemName: "sun.max.fill")
                    }
                }
                .tag(MainCoordinator.Tab.dashboard)

            historyView
                .tabItem {
                    Label {
                        Text(FeatureNavigationStrings.Tab.history)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }
                .tag(MainCoordinator.Tab.history)

            profileView
                .tabItem {
                    Label {
                        Text(
                            coordinator.profileTabTitle.isEmpty
                                ? SharedLocalizedString.Auth.profile
                                : coordinator.profileTabTitle
                        )
                    } icon: {
                        Image(systemName: "person.crop.circle")
                    }
                }
                .tag(MainCoordinator.Tab.profile)
        }
    }
}
