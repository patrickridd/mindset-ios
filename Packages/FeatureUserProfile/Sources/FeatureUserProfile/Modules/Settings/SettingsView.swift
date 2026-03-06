//
//  SettingsView.swift
//  FeatureUserProfile
//
//  Created by patrick ridd on 3/3/26.
//

import Domain
import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

public struct SettingsView: View {

    @Bindable private var viewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: MindsetLayout.spacing24) {
                    securityAndPrivacyCard
                    signOutButton
                    deleteAccountButton
                }
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                .padding(.top, MindsetLayout.spacing30)
            }

            loadingOverlay
                .opacity(viewModel.isBusy ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isBusy)
        }
        .navigationTitle("Security and Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.activeSheet) { sheet in
            confirmationSheet(for: sheet)
        }
        .alert(
            Text(viewModel.errorTitle),
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.dismissError() } }
            )
        ) {
            Button(SharedLocalizedString.ok) {
                viewModel.dismissError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    private func confirmAndSignOut() {
        Task { await viewModel.signOut() }
    }

    private func confirmAndDeleteAccount() {
        Task { await viewModel.deleteAccount() }
    }

    private func privacyPolicyTapped() {
        viewModel.navigateToPrivacyPolicy()
    }

    @ViewBuilder
    private func confirmationSheet(for sheet: SettingsSheet) -> some View {
        switch sheet {
        case .signOut:
            SignOutConfirmationSheet(
                onConfirm: confirmAndSignOut,
                onCancel: viewModel.cancelSignOut
            )
        case .deleteAccount:
            ConfirmationSheet(
                title: FeatureUserProfileStrings.DeleteAccount.confirmationTitle,
                subtitle: FeatureUserProfileStrings.DeleteAccount.confirmationSubtitle,
                confirmTitle: FeatureUserProfileStrings.DeleteAccount.confirmButton,
                confirmStyle: .destructive,
                onConfirm: confirmAndDeleteAccount,
                onCancel: viewModel.cancelDeleteAccount
            )
        }
    }
}

// MARK: - Subviews

extension SettingsView {

    private var securityAndPrivacyCard: some View {
        VStack(spacing: 0) {
            AccountRow(
                icon: "checkmark.shield.fill",
                title: FeatureUserProfileStrings.Account.signedInTitle,
                subtitle: FeatureUserProfileStrings.Account.signedInSubtitle,
                color: MindsetColors.successEmerald
            )

            rowDivider

            AccountNavigationRow(
                icon: "hand.raised.fill",
                title: FeatureUserProfileStrings.Legal.privacyPolicyTitle,
                subtitle: FeatureUserProfileStrings.Legal.privacyPolicySubtitle,
                color: MindsetColors.stoicSlate,
                navigationAction: privacyPolicyTapped
            )
            .disabled(viewModel.isBusy)
        }
        .mindsetCard()
    }

    private var signOutButton: some View {
        Button {
            HapticManager.selection()
            viewModel.presentConfirmSignOut()
        } label: {
            HStack(spacing: MindsetLayout.spacing12) {
                MindsetIconButton(
                    icon: "rectangle.portrait.and.arrow.right",
                    color: MindsetColors.accentCoral,
                    iconFont: .system(size: 20),
                    leadingPadding: MindsetLayout.spacing5
                )
                Text(SharedLocalizedString.Auth.signOut)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
            }
            .foregroundStyle(MindsetColors.accentCoral)
            .frame(maxWidth: .infinity)
            .frame(height: MindsetLayout.buttonHeight)
        }
        .disabled(viewModel.isBusy)
        .mindsetButton()
    }

    private var deleteAccountButton: some View {
        Button {
            HapticManager.selection()
            viewModel.presentDeleteAccountConfirmation()
        } label: {
            HStack(spacing: MindsetLayout.spacing12) {
                MindsetIconButton(
                    icon: "trash",
                    color: MindsetColors.accentDestructiveRed,
                    iconFont: .system(size: 20)
                )

                Text(FeatureUserProfileStrings.DeleteAccount.buttonTitle)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
            }
            .foregroundStyle(MindsetColors.accentDestructiveRed)
            .frame(maxWidth: .infinity)
            .frame(height: MindsetLayout.buttonHeight)
        }
        .disabled(viewModel.isBusy)
        .mindsetDestructiveButton()
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: MindsetLayout.spacing20) {
                ProgressView()
                    .tint(MindsetColors.accentOrange)
                    .scaleEffect(1.5)

                Text(viewModel.busyOverlayText)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textPrimary)
            }
            .padding(MindsetLayout.paddingCard)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                    .fill(MindsetColors.backgroundDarkSoft)
            )
        }
    }

    private var rowDivider: some View {
        MindsetColors.stoicSlateSoft
            .frame(height: 0.5)
            .padding(.leading, MindsetLayout.iconButtonLarge + MindsetLayout.spacing30)
    }
}

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(
            authService: MockAuthService(),
            persistence: PreviewPersistenceService(),
            onSignOut: {},
            onDeleteAccount: {},
            onNavigateToPrivacyPolicy: {}
        )
    )
}

private struct PreviewPersistenceService: PersistenceService {
    func saveUserProfile(_ profile: UserProfile) async throws {}
    func fetchUserProfile() async throws -> UserProfile? { nil }
    func saveMindsetEntry(_ entry: MindsetEntry) async throws {}
    func fetchAllMindsetEntries() async throws -> [MindsetEntry] { [] }
    func deleteAllUserData() async throws {}
}
