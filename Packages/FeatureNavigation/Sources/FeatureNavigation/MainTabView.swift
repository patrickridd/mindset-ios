//
//  MainTabView.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 1/20/26.
//

import SwiftUI

public struct MainTabView: View {
    @Bindable var coordinator: MainCoordinator
    private let dashboardView: AnyView
    private let historyView: AnyView
    
    public init(coordinator: MainCoordinator, dashboardView: AnyView, historyView: AnyView) {
        self.coordinator = coordinator
        self.dashboardView = dashboardView
        self.historyView = historyView
    }
    
    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            dashboardView
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
                .tag(MainCoordinator.Tab.dashboard)
            
            historyView
                .tabItem { Label("History", systemImage: "calendar") }
                .tag(MainCoordinator.Tab.history)
        }
    }
}
