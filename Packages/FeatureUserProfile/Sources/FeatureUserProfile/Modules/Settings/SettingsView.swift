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
                    AccountRow(
                        icon: "checkmark.shield.fill",
                        title: FeatureUserProfileStrings.Account.signedInTitle,
                        subtitle: FeatureUserProfileStrings.Account.signedInSubtitle,
                        color: MindsetColors.successEmerald
                    )

                    Divider()
                    
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
            .presentationDetents([.height(MindsetLayout.detentSmall)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(MindsetLayout.radiusCardLarge)
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

    private var signOutButton: some View {
        Button {
            HapticManager.selection()
            viewModel.confirmSignOut()
        } label: {
            HStack(spacing: MindsetLayout.spacing12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: MindsetLayout.iconLarge))

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
            viewModel.confirmDeleteAccount()
        } label: {
            HStack(spacing: MindsetLayout.spacing12) {
                Image(systemName: "trash.fill")
                    .font(.system(size: MindsetLayout.iconLarge))

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
}

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(
            authService: MockAuthService(),
            persistence: PreviewPersistenceService(),
            onSignOut: {}
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
