//
//  AppViewFactory.swift
//  mindset-ios
//
//  Created by patrick ridd on 1/11/26.
//

import Data
import Domain
#if DEBUG
import Development
#endif
import FeatureAuth
import FeatureDashboard
import FeatureHistory
import FeatureMindset
import FeatureNavigation
import FeatureOnboarding
import FeatureSubscription
import FeatureUserProfile
import SharedUI
import SharedUtils
import SwiftUI

#if DEBUG
private struct DebugPresentationWrapper: View {
    @ObserveInjection var inject
    let content: AnyView

    var body: some View {
        content
            .enableInjection()
            .modifier(DebugWrapper())
    }
}
#endif

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
    let persistence: PersistenceService
    let logger: AppLogger

    func decoratePresentedView(_ view: AnyView) -> AnyView {
        #if DEBUG
        AnyView(DebugPresentationWrapper(content: view))
        #else
        view
        #endif
    }

    func makeSignInView() -> AnyView {
        let viewModel = SignInViewModel(
            authService: authService,
            logger: logger,
            onSignInSuccess: { userID in
                coordinator.signInCompleted()
            },
            onSkip: {
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
                coordinator.dismissFullScreen()
            })
        return AnyView(
            PaywallView(viewModel: viewModel)
        )
    }

    func makeTabView() -> AnyView {
        AnyView(
            MainTabView(
                coordinator: coordinator,
                dashboardView: makeDashboardView(),
                historyView: makeMindsetHistoryView(),
                profileView: makeUserProfileView()
            )
        )
    }
    
    func makeDashboardView() -> AnyView {
        let dashboardViewModel = DashboardViewModel(
            userRepository: userRepository,
            mindsetRepository: mindsetRepository,
            getStreakUseCase: getStreakUseCase,
            getYesterdayGoalUseCase: getYesterdayGoalUseCase,
            logger: logger,
            onStartMindset: {
                coordinator.startMorningMindset()
            },
            onSeeHistory: {
                coordinator.set(tab: .history)
            })
        return AnyView(DashboardView(viewModel: dashboardViewModel))
    }

    func makeUserProfileView() -> AnyView {
        let isDebugToolsAvailable: Bool = {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }()

        let profileViewModel = UserProfileViewModel(
            authService: authService,
            userRepository: userRepository,
            isDebugToolsAvailable: isDebugToolsAvailable,
            onNavigateToSecurity: {
                coordinator.profilePath.append(ProfileDestination.security)
            },
            onNavigateToDebugTools: {
                coordinator.profilePath.append(ProfileDestination.debugTools)
            }
        )
        #if DEBUG
        let debugViewModel = DebugToolsViewModel()
        #endif

        return AnyView(
            NavigationStack(path: Bindable(coordinator).profilePath) {
                UserProfileView(viewModel: profileViewModel)
                    .navigationDestination(for: ProfileDestination.self) { destination in
                        switch destination {
                        case .debugTools:
                            #if DEBUG
                            DebugToolsView(viewModel: debugViewModel)
                                .navigationTitle(FeatureUserProfileStrings.DebugTools.title)
                            #else
                            EmptyView()
                            #endif
                        case .security:
                            SettingsView(
                                viewModel: SettingsViewModel(
                                    authService: authService,
                                    persistence: persistence,
                                    onSignOut: {
                                        coordinator.signOutCompleted()
                                    }
                                )
                            )
                        }
                    }
            }
        )
    }

    func makeMindsetHistoryView() -> AnyView {
        let viewModel = MindsetHistoryViewModel(repository: mindsetRepository, logger: logger)
        return AnyView(MindsetHistoryView(viewModel: viewModel))
    }

    func makeMindsetRitualView() -> AnyView {
        let aiService = serviceFactory.makeAIService()
        let viewModel = MorningRitualViewModel(
            userRepository: userRepository,
            addMindsetUseCase: addMindsetUseCase,
            subscriptionService: subscriptionService,
            aiService: aiService,
            logger: logger,
            onNavigate: { state in
                switch state {
                case .success(let archetype, let xp):
                    coordinator.showRitualSuccess(archetype: archetype, xp: xp)
                case .paywall:
                    coordinator.showPaywall()
                }
            },
            onDismiss: { coordinator.showMainTabView() })

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
                coordinator.showMainTabView()
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
