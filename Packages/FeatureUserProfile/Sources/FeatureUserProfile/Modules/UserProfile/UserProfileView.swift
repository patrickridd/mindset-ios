//
//  UserProfileView.swift
//  FeatureUserProfile
//
//  Created by Mindset Team on 2/1/26.
//

import Domain
import SharedLocalization
import SharedUI
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
                }
                .padding(.horizontal, MindsetLayout.paddingMedium)
                .padding(.top, MindsetLayout.spacing30)
            }
        }
    }

    private var avatarBackgroundOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.2
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
                title: "Settings",
                subtitle: "Security, privacy, data protection",
                color: MindsetColors.accentOrange,
                navigationAction: { viewModel.navigateToSecurity() }
            )
        }
        .mindsetCard()
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
        onNavigateToSecurity: {}
    )
    return UserProfileView(viewModel: viewModel)
}

