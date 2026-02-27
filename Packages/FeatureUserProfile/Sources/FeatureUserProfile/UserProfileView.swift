//
//  UserProfileView.swift
//  FeatureUserProfile
//
//  Created by Mindset Team on 2/1/26.
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

public struct UserProfileView: View {
    #if DEBUG
        @ObserveInjection var inject
    #endif

    @State private var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) private var colorScheme

    public init(viewModel: UserProfileViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Background
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: MindsetLayout.spacing24) {
                    // Profile Header
                    profileHeader

                    // Account Section
                    accountSection

                    // Sign Out Button
                    signOutButton

                    Spacer()
                }
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                .padding(.top, MindsetLayout.spacing30)
            }

            // Loading overlay
            if viewModel.isSigningOut {
                loadingOverlay
            }
        }
        .confirmationDialog(
            "Are you sure you want to sign out?",
            isPresented: $viewModel.showSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                Task {
                    await viewModel.signOut()
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelSignOut()
            }
        }
        .alert("Sign Out Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
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

    private var profileHeader: some View {
        VStack(spacing: MindsetLayout.spacing16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(MindsetColors.accentOrange.opacity(colorScheme == .dark ? 0.15 : 0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(MindsetColors.accentOrange)
            }

            // Display Name
            Text(viewModel.displayName ?? "Mindset User")
                .font(MindsetFonts.featureTitle)
                .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))

            // User ID (truncated)
            if let userID = viewModel.userID {
                Text("ID: \(userID.prefix(8))...")
                    .font(MindsetFonts.caption)
                    .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MindsetLayout.spacing24)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text("Account")
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .padding(.horizontal, MindsetLayout.paddingMedium)

            VStack(spacing: 0) {
                accountRow(
                    icon: "checkmark.shield.fill",
                    title: "Signed In",
                    subtitle: "Your data is secure",
                    color: MindsetColors.successEmerald,
                    colorScheme: colorScheme
                )

                Rectangle()
                    .fill(MindsetColors.stoicSlateSoft)
                    .frame(height: 1)
                    .padding(.leading, 60)

                accountRow(
                    icon: "icloud.fill",
                    title: "Cloud Sync",
                    subtitle: "All devices synced",
                    color: MindsetColors.accentBlue,
                    colorScheme: colorScheme
                )
            }
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                    .fill(MindsetColors.backgroundCard(for: colorScheme))
            )
        }
    }

    private func accountRow(
        icon: String, title: String, subtitle: String, color: Color, colorScheme: ColorScheme
    ) -> some View {
        HStack(spacing: MindsetLayout.spacing16) {
            ZStack {
                Circle()
                    .fill(color.opacity(colorScheme == .dark ? 0.15 : 0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
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

    private var signOutButton: some View {
        Button {
            HapticManager.selection()
            viewModel.confirmSignOut()
        } label: {
            HStack(spacing: MindsetLayout.spacing12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18))

                Text("Sign Out")
                    .font(MindsetFonts.button)
            }
            .foregroundStyle(MindsetColors.accentCoral)
            .frame(maxWidth: .infinity)
            .frame(height: MindsetLayout.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                    .fill(MindsetColors.accentCoral.opacity(colorScheme == .dark ? 0.1 : 0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                    .stroke(
                        MindsetColors.accentCoral.opacity(colorScheme == .dark ? 0.3 : 0.4),
                        lineWidth: 1)
            )
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

                Text("Signing out...")
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
    let mockAuthService = MockAuthService()
    let mockUserRepository = MockUserRepository()
    let viewModel = UserProfileViewModel(
        authService: mockAuthService,
        userRepository: mockUserRepository,
        onSignOut: {}
    )
    return UserProfileView(viewModel: viewModel)
}
