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
    
    @Bindable var viewModel: UserProfileViewModel
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
                    #if DEBUG
                    debugSection
                    #endif
                    signOutButton
                    Spacer()
                }
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                .padding(.top, MindsetLayout.spacing30)
            }

            loadingOverlay
                .opacity(viewModel.isSigningOut ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSigningOut)
        }
        .sheet(isPresented: $viewModel.showSignOutConfirmation) {
            SignOutConfirmationSheet(
                onConfirm: {
                    Task { await viewModel.signOut() }
                },
                onCancel: {
                    viewModel.cancelSignOut()
                }
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
        .alert("Restarting App", isPresented: $viewModel.showRestartAlert) {
            Button(SharedLocalizedString.ok, role: .cancel) {
                HapticManager.action()
                viewModel.restartApp()
            }
        } message: {
            Text(viewModel.environmentDescription)
        }
    }
}

// MARK: - Subviews

extension UserProfileView {

    private var profileHeader: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            ZStack {
                Circle()
                    .fill(MindsetColors.accentOrange.opacity(colorScheme == .dark ? 0.15 : 0.2))
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
            // A Row that navigates
            AccountNavigationRow(
                icon: "person.badge.key.fill",
                title: "Security Settings",
                subtitle: "Manage your recovery keys",
                color: MindsetColors.accentOrange,
                action: {
             //       viewModel.navigateToSecurity()
                }
            )

            divider // Your existing Rectangle() divider

            // A static row (like your current "Signed In" indicator)
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
    
#if DEBUG
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text("DEBUG TOOLS")
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(.secondary)
                .padding(.horizontal, MindsetLayout.paddingMedium)
            
            VStack(spacing: 0) {
                Toggle("Use Mock Services", isOn: $viewModel.useMocks)
                    .font(MindsetFonts.bodyMedium)
                    .padding(MindsetLayout.paddingMedium)
            }
            .mindsetCard()
        }
    }
#endif

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

