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
    #if DEBUG
        @ObserveInjection var inject
    #endif

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
            .presentationDetents([.height(300)])
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
        #if DEBUG
            .enableInjection()
        #endif
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

            accountCard
        }
    }

    @ViewBuilder
    private var accountCard: some View {
        if #available(iOS 26, *) {
            accountCardRows
                .glassEffect(.regular, in: .rect(cornerRadius: MindsetLayout.radiusCard))
        } else {
            accountCardRows
                .background(
                    RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                        .fill(MindsetColors.backgroundCard(for: colorScheme))
                )
        }
    }

    private var accountCardRows: some View {
        VStack(spacing: 0) {
            AccountRow(
                icon: "checkmark.shield.fill",
                title: FeatureUserProfileStrings.Account.signedInTitle,
                subtitle: FeatureUserProfileStrings.Account.signedInSubtitle,
                color: MindsetColors.successEmerald
            )

            Rectangle()
                .fill(MindsetColors.stoicSlateSoft)
                .frame(height: MindsetLayout.borderWidth)
                .padding(.leading, MindsetLayout.iconButtonLarge + MindsetLayout.spacing16)

            AccountRow(
                icon: "icloud.fill",
                title: FeatureUserProfileStrings.Account.cloudSyncTitle,
                subtitle: FeatureUserProfileStrings.Account.cloudSyncSubtitle,
                color: MindsetColors.accentBlue
            )
        }
    }

    @ViewBuilder
    private var signOutButton: some View {
        if #available(iOS 26, *) {
            signOutButtonBase
                .glassEffect(
                    .regular.tint(MindsetColors.accentCoral.opacity(0.15)).interactive(),
                    in: .rect(cornerRadius: MindsetLayout.radiusButton)
                )
        } else {
            signOutButtonBase
                .background(
                    RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                        .fill(MindsetColors.accentCoral.opacity(colorScheme == .dark ? 0.1 : 0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                                .stroke(
                                    MindsetColors.accentCoral.opacity(
                                        colorScheme == .dark ? 0.3 : 0.4),
                                    lineWidth: MindsetLayout.borderWidth)
                        )
                )
        }
    }

    private var signOutButtonBase: some View {
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
}

// MARK: - AccountRow

private struct AccountRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: MindsetLayout.spacing16) {
            ZStack {
                Circle()
                    .fill(color.opacity(colorScheme == .dark ? 0.15 : 0.2))
                    .frame(
                        width: MindsetLayout.iconButtonLarge,
                        height: MindsetLayout.iconButtonLarge)

                Image(systemName: icon)
                    .font(.system(size: MindsetLayout.iconLarge))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: MindsetLayout.spacing4) {
                Text(title)
                    .font(MindsetFonts.bodyMedium)
                    .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))

                Text(subtitle)
                    .font(MindsetFonts.caption)
                    .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
            }

            Spacer()
        }
        .padding(MindsetLayout.paddingMedium)
    }
}

#Preview {
    let mockAuthService = MockAuthService()
    let mockUserRepository = MockUserRepository()
    let viewModel = UserProfileViewModel(
        authService: mockAuthService,
        userRepository: mockUserRepository,
        onSignOut: {}
    )
    return UserProfileView(viewModel: viewModel)
}

