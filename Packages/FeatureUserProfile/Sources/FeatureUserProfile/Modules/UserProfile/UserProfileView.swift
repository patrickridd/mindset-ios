//
//  UserProfileView.swift
//  FeatureUserProfile
//
//  Created by Mindset Team on 2/1/26.
//

import Domain
import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

public struct UserProfileView: View {

    @Bindable private var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) private var colorScheme

    public init(viewModel: UserProfileViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: MindsetLayout.spacing24) {
                    profileHeader
                    accountSection
                    if viewModel.isDebugToolsAvailable {
                        debugSection
                    }
                    signOutButton
                }
                .padding(.horizontal, MindsetLayout.paddingMedium)
                .padding(.top, MindsetLayout.spacing30)
            }

            loadingOverlay
                .opacity(viewModel.isSigningOut ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSigningOut)
        }
        .sheet(isPresented: $viewModel.showSignOutConfirmation) {
            SignOutConfirmationSheet(
                onConfirm: confirmAndSignOut,
                onCancel: viewModel.cancelSignOut
            )
            .presentationDetents([.height(MindsetLayout.detentSmall)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(MindsetLayout.radiusCardLarge)
        }
        .alert(
            FeatureUserProfileStrings.SignOut.errorTitle,
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

    private var avatarBackgroundOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.2
    }

    private func confirmAndSignOut() {
        Task { await viewModel.signOut() }
    }
}

// MARK: - Subviews

extension UserProfileView {

    private var profileHeader: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            ZStack {
                Circle()
                    .fill(MindsetColors.accentOrange.opacity(avatarBackgroundOpacity))
                    .frame(width: MindsetLayout.avatarSize, height: MindsetLayout.avatarSize)

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: MindsetLayout.avatarIconSize))
                    .foregroundStyle(MindsetColors.accentOrange)
            }

            Text(viewModel.displayName ?? FeatureUserProfileStrings.defaultUserName)
                .font(MindsetFonts.featureTitle)
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))

            if let userID = viewModel.userID {
                Text("\(FeatureUserProfileStrings.userIdPrefix) \(userID.prefix(8))...")
                    .font(MindsetFonts.caption)
                    .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MindsetLayout.spacing24)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(SharedLocalizedString.Auth.account)
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .padding(.horizontal, MindsetLayout.paddingMedium)

            accountCardRows
        }
    }

    private var accountCardRows: some View {
        VStack(spacing: 0) {
            AccountNavigationRow(
                icon: "person.badge.key.fill",
                title: "Security and Privacy",
                subtitle: "Password, device security, data protection",
                color: MindsetColors.accentOrange,
                navigationAction: { viewModel.navigateToSecurity() }
            )

            divider

            AccountRow(
                icon: "checkmark.shield.fill",
                title: FeatureUserProfileStrings.Account.signedInTitle,
                subtitle: FeatureUserProfileStrings.Account.signedInSubtitle,
                color: MindsetColors.successEmerald
            )
        }
        .mindsetCard()
    }

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
            }
            .foregroundStyle(MindsetColors.accentCoral)
            .frame(maxWidth: .infinity)
            .frame(height: MindsetLayout.buttonHeight)
        }
        .disabled(viewModel.isSigningOut)
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

                Text(FeatureUserProfileStrings.SignOut.signingOut)
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
    
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(FeatureUserProfileStrings.DebugTools.title)
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .padding(.horizontal, MindsetLayout.paddingMedium)

            AccountNavigationRow(
                icon: "wrench.and.screwdriver.fill",
                title: FeatureUserProfileStrings.DebugTools.title,
                subtitle: FeatureUserProfileStrings.DebugTools.rowSubtitle,
                color: MindsetColors.stoicSlate,
                navigationAction: { viewModel.navigateToDebugTools() }
            )
            .mindsetCard()
        }
    }

    private var divider: some View {
        MindsetColors.stoicSlateSoft
            .frame(height: 0.5)
            .padding(.leading, MindsetLayout.iconButtonLarge + MindsetLayout.spacing30)
    }
}

#Preview {
    let mockAuthService = MockAuthService()
    let mockUserRepository = MockUserRepository()
    let viewModel = UserProfileViewModel(
        authService: mockAuthService,
        userRepository: mockUserRepository,
        onNavigateToSecurity: {},
        onSignOut: {}
    )
    return UserProfileView(viewModel: viewModel)
}

