//
//  AppViewFactory.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/11/26.
//

import Data
import Domain
import FeatureAuth
import FeatureDashboard
import FeatureHistory
import FeatureMindset
import FeatureNavigation
import FeatureOnboarding
import FeatureSubscription
import FeatureUserProfile
import SharedUtils
import SharedUI
import SwiftUI

struct AppViewFactory: MainViewFactory {
    let coordinator: MainCoordinator
    let authService: AuthService
    let userRepository: UserRepository
    let mindsetRepository: MindsetRepository
    let getStreakUseCase: GetStreakUseCase
    let addMindsetUseCase: AddMindsetUseCase
    let getYesterdayGoalUseCase: GetYesterdayGoalUseCase
    let subscriptionService: SubscriptionService
    let serviceFactory: ServiceFactory

    func makeSignInView() -> AnyView {
        let viewModel = SignInViewModel(
            authService: authService,
            onSignInSuccess: { userID in
                DebugLogger.shared.add("✅ User signed in: \(userID)")
                coordinator.signInCompleted()
            },
            onSkip: {
                DebugLogger.shared.add("⏭️ User skipped sign in (anonymous)")
                coordinator.signInCompleted()
            }
        )

        return AnyView(
            SignInView(viewModel: viewModel)
        )
    }

    func makeOnboardingView() -> AnyView {
        let viewModel = OnboardingViewModel(
            userRepository: userRepository,
            onboardingFinished: {
                // Let MainCoordinator handle Auth → Paywall → Home flow
                coordinator.onboardingFinished()
            })

        return AnyView(
            OnboardingView(viewModel: viewModel)
        )
    }

    func makePaywallView() -> AnyView {
        let viewModel = PaywallViewModel(
            subscriptionService: subscriptionService,
            onPurchaseFinished: {
                // Dismiss paywall overlay - already at .home root state
                coordinator.dismissFullScreen()
            })
        return AnyView(
            PaywallView(viewModel: viewModel)
        )
    }

    func makeHomeView() -> AnyView {
        let dashboardViewModel = DashboardViewModel(
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreakUseCase,
            getYesterdayGoalUseCase: getYesterdayGoalUseCase,
            onStartMindset: {
                coordinator.startMorningMindset()
            },
            onSeeHistory: {
                coordinator.set(tab: .history)
            })

        let historyViewModel = MindsetHistoryViewModel(repository: mindsetRepository)

        let profileViewModel = UserProfileViewModel(
            authService: authService,
            userRepository: userRepository,
            onSignOut: {
                coordinator.signOutCompleted()
            }
        )

        return AnyView(
            MainTabView(
                coordinator: coordinator,
                dashboardView: AnyView(DashboardView(viewModel: dashboardViewModel)),
                historyView: AnyView(MindsetHistoryView(viewModel: historyViewModel)),
                profileView: AnyView(UserProfileView(viewModel: profileViewModel)))
        )
    }

    func makeMindsetView() -> AnyView {
        let aiService = serviceFactory.makeAIService()
        let viewModel = MorningRitualViewModel(
            userRepository: userRepository,
            addMindsetUseCase: addMindsetUseCase,
            subscriptionService: subscriptionService,
            aiService: aiService,
            onNavigate: { state in
                switch state {
                case .success(let archetype, let xp):
                    coordinator.showRitualSuccess(archetype: archetype, xp: xp)
                case .paywall:
                    coordinator.showPaywall()
                }
            },
            onDismiss: { coordinator.showHomeView() })

        return AnyView(
            // Bind the stack to the coordinator's path
            NavigationStack(path: Bindable(coordinator).mindsetPath) {
                MorningRitualView(viewModel: viewModel)
                    .navigationDestination(for: RitualResult.self) { result in
                        // The factory uses the coordinator's data to build the next view
                        self.makeRitualSuccessView(archetype: result.archetype, xp: result.xp)
                            .navigationBarBackButtonHidden()
                    }
            }
        )
    }

    func makeRitualSuccessView(archetype: String, xp: Int) -> AnyView {
        AnyView(
            RitualSuccessView(archetype: archetype, xpEarned: xp) {
                coordinator.showHomeView()
                coordinator.dismissSheet()
            })
    }

    func makeLoadingView() -> AnyView {
        AnyView(
            ZStack {
                Circle()
                    .fill(MindsetColors.accentOrange.opacity(0.15))
                    .frame(width: MindsetLayout.iconLarge, height: MindsetLayout.iconLarge)
                    .blur(radius: MindsetLayout.glowBlurRadius)
                
                ProgressView()
                    .tint(MindsetColors.accentOrange)
                    .scaleEffect(2)
            }
        )
    }
}
