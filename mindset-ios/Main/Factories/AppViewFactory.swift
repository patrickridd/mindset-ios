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
import FeatureStart
import FeatureSubscription
import FeatureUserProfile
import Foundation
import SharedUI
import SharedUtils
import SwiftUI

#if DEBUG
    import Development
#endif

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
    let signInOrLinkUseCase: SignInOrLinkUseCase
    let userRepository: UserRepository
    let entryRepository: EntryRepository
    let syncService: AppSyncService
    let getStreakUseCase: GetStreakUseCase
    let addEntryUseCase: AddEntryUseCase
    let deleteAccountUseCase: DeleteAccountUseCase
    let signOutUseCase: SignOutUseCase
    let getYesterdayGoalUseCase: GetYesterdayGoalUseCase
    let subscriptionService: SubscriptionService
    let serviceFactory: ServiceFactory
    let logger: AppLogger
    let appleSignInNonceStorage: AppleSignInNonceStorageProtocol

    private var appleSignInCredentialBuilder: AppleSignInCredentialBuilderProtocol {
        AppleSignInCredentialBuilder(nonceStorage: appleSignInNonceStorage)
    }

    func decoratePresentedView(_ view: AnyView) -> AnyView {
        #if DEBUG
            AnyView(DebugPresentationWrapper(content: view))
        #else
            view
        #endif
    }

    func makeStartView() -> AnyView {
        let startListViewModel = StartViewModel(
            signInService: authService,
            userRepository: userRepository,
            logger: logger,
            onGetStarted: {
                coordinator.startPath.append(StartDestination.onboarding)
            },
            onAlreadyHaveAccount: {
                coordinator.startPath.append(StartDestination.signIn)
            },
            onGuestSignedIn: {
                coordinator.showDashboard()
            }
        )

        let funnelOnboardingViewModel = OnboardingViewModel(
            userRepository: userRepository,
            signInService: authService,
            authStateQuery: authService,
            onboardingFinished: {
                coordinator.onboardingFinished()
            },
            usesEmbeddedNavigationStack: false
        )

        let funnelSignInViewModel = SignInViewModel(
            signInOrLinkUseCase: signInOrLinkUseCase,
            appleSignInCredentialBuilder: appleSignInCredentialBuilder,
            googleSignInCredentialProvider: serviceFactory.makeGoogleSignInCredentialProvider(),
            phoneVerificationProvider: serviceFactory.makePhoneVerificationProvider(),
            logger: logger,
            embedInNavigationStack: false,
            onPhoneSignInButtonTapped: {
                coordinator.startPath.append(StartDestination.phoneSignIn)
            },
            onSignInSuccess: { _ in
                coordinator.signInCompleted()
            },
            onSkip: {
                coordinator.signInCompleted()
            }
        )

        return AnyView(
            NavigationStack(path: Bindable(coordinator).startPath) {
                StartView(viewModel: startListViewModel)
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(for: StartDestination.self) { destination in
                        switch destination {
                        case .onboarding:
                            OnboardingView(viewModel: funnelOnboardingViewModel)
                        case .signIn:
                            SignInView(viewModel: funnelSignInViewModel)
                        case .phoneSignIn:
                            let phoneSignInViewModel = PhoneSignInViewModel(
                                signInViewModel: funnelSignInViewModel)
                            PhoneSignInView(phoneViewModel: phoneSignInViewModel)
                        }
                    }
            }
        )
    }

    func makeSignInView() -> AnyView {
        let signInViewModel = SignInViewModel(
            signInOrLinkUseCase: signInOrLinkUseCase,
            appleSignInCredentialBuilder: appleSignInCredentialBuilder,
            googleSignInCredentialProvider: serviceFactory.makeGoogleSignInCredentialProvider(),
            phoneVerificationProvider: serviceFactory.makePhoneVerificationProvider(),
            logger: logger,
            onPhoneSignInButtonTapped: {
                coordinator.signInPath.append(SignInDestination.phoneSignIn)
            },
            onSignInSuccess: { _ in
                coordinator.signInCompleted()

                let pathCount = coordinator.signInPath.count
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 1.0,
                    execute: {
                        coordinator.signInPath.removeLast(pathCount)
                    })
            },
            onSkip: {
                coordinator.signInCompleted()
            }
        )
        return AnyView(
            NavigationStack(path: Bindable(coordinator).signInPath) {
                SignInView(viewModel: signInViewModel)
                    .navigationDestination(for: SignInDestination.self) { destination in
                        switch destination {
                        case .phoneSignIn:
                            let phoneSignInViewModel = PhoneSignInViewModel(signInViewModel: signInViewModel)
                            PhoneSignInView(phoneViewModel: phoneSignInViewModel)
                        }
                    }
            }
        )
    }

    func makeOnboardingView() -> AnyView {
        let viewModel = OnboardingViewModel(
            userRepository: userRepository,
            signInService: authService,
            authStateQuery: authService,
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
            entryRepository: entryRepository,
            getStreakUseCase: getStreakUseCase,
            getYesterdayGoalUseCase: getYesterdayGoalUseCase,
            syncService: syncService,
            logger: logger,
            onStartMindset: {
                coordinator.startMorningMindset()
            },
            onSeeHistory: {
                coordinator.set(tab: .history)
            },
            onSecureAccount: {
                coordinator.showAuth()
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

        let privacyPolicyURL = URL(string: "https://mindset.app/privacy")!

        let profileViewModel = UserProfileViewModel(
            authStateQuery: authService,
            userRepository: userRepository,
            isDebugToolsAvailable: isDebugToolsAvailable,
            onNavigateToSecurity: {
                coordinator.profilePath.append(ProfileDestination.security)
            },
            onNavigateToDebugTools: {
                coordinator.profilePath.append(ProfileDestination.debugTools)
            }
        )
        let signInViewModel = SignInViewModel(
            signInOrLinkUseCase: signInOrLinkUseCase,
            appleSignInCredentialBuilder: appleSignInCredentialBuilder,
            googleSignInCredentialProvider: serviceFactory.makeGoogleSignInCredentialProvider(),
            phoneVerificationProvider: serviceFactory.makePhoneVerificationProvider(),
            logger: logger,
            embedInNavigationStack: false,
            onPhoneSignInButtonTapped: {
                coordinator.profilePath.append(ProfileDestination.phoneSignIn)
            },
            onSignInSuccess: { _ in
                // Pop back to "Security and Settings"
                coordinator.refreshProfileTabTitle()
                let profilePathCount = coordinator.profilePath.count - 1
                coordinator.profilePath.removeLast(profilePathCount)
            },
            onSkip: {
                // No skipping option in UserProfile
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
                            makeSettingsView()
                        case .privacyPolicy:
                            PrivacyPolicyView(url: privacyPolicyURL)
                        case .signInView:
                            SignInView(viewModel: signInViewModel)
                        case .phoneSignIn:
                            let phoneSignInViewModel = PhoneSignInViewModel(signInViewModel: signInViewModel)
                            PhoneSignInView(phoneViewModel: phoneSignInViewModel)
                        }
                    }
            }
        )
    }

    func makeSettingsView() -> AnyView {
        let viewModel = SettingsViewModel(
            authSessionManagement: authService,
            authStateQuery: authService,
            deleteAccountUseCase: deleteAccountUseCase, signOutUseCase: signOutUseCase,
            onSignOut: {
                coordinator.signOutCompleted()
            },
            onDeleteAccount: {
                coordinator.accountDeleted()
            },
            onNavigateToPrivacyPolicy: {
                coordinator.profilePath.append(ProfileDestination.privacyPolicy)
            },
            onNavigateToSecureAccount: {
                coordinator.profilePath.append(ProfileDestination.signInView)
            }
        )
        return AnyView(SettingsView(viewModel: viewModel))
    }

    func makeMindsetHistoryView() -> AnyView {
        let viewModel = MindsetHistoryViewModel(entryRepository: entryRepository, syncService: syncService, logger: logger)
        return AnyView(MindsetHistoryView(viewModel: viewModel))
    }

    func makeMindsetRitualView() -> AnyView {
        let aiService = serviceFactory.makeAIService()
        let viewModel = MindsetPracticeFlowViewModel(
            userRepository: userRepository,
            addEntryUseCase: addEntryUseCase,
            subscriptionService: subscriptionService,
            getStreakUseCase: getStreakUseCase,
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
                MindsetPracticeFlowView(viewModel: viewModel)
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
            PracticeSuccessView(archetype: archetype, xpEarned: xp) {
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
