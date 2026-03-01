//
//  DebugToolsView.swift
//  FeatureUserProfile
//

#if DEBUG
import Domain
import SharedUI
import SharedUtils
import SwiftUI

public struct DebugToolsView: View {
    @Bindable var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) private var colorScheme

    public init(viewModel: UserProfileViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body Composition

    public var body: some View {
        ZStack {
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: MindsetLayout.spacing24) {
                    servicesSection
                    Spacer()
                }
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                .padding(.top, MindsetLayout.spacing30)
            }
        }
        .navigationTitle(FeatureUserProfileStrings.DebugTools.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Restarting App", isPresented: $viewModel.showRestartAlert) {
            Button(role: .cancel) {
                HapticManager.action()
                viewModel.restartApp()
            } label: {
                Text("OK")
            }
        } message: {
            Text(viewModel.environmentDescription)
        }
    }
}

// MARK: - Subviews

private extension DebugToolsView {
    var servicesSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(FeatureUserProfileStrings.DebugTools.sectionHeader)
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .padding(.horizontal, MindsetLayout.paddingMedium)

            VStack(spacing: 0) {
                Toggle(FeatureUserProfileStrings.DebugTools.useMockServices, isOn: $viewModel.useMocks)
                    .font(MindsetFonts.bodyMedium)
                    .tint(MindsetColors.accentOrange)
                    .padding(MindsetLayout.paddingMedium)
            }
            .mindsetCard()
        }
    }
}

#Preview {
    NavigationStack {
        DebugToolsView(
            viewModel: UserProfileViewModel(
                authService: MockAuthService(),
                userRepository: MockUserRepository(),
                onNavigateToSecurity: {},
                onSignOut: {}
            )
        )
    }
}
#endif
