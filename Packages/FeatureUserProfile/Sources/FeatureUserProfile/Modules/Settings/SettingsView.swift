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
                    signOutButton
                }
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                .padding(.top, MindsetLayout.spacing30)
            }

            loadingOverlay
                .opacity(viewModel.isSigningOut ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSigningOut)
        }
        .navigationTitle("Security and Privacy")
        .navigationBarTitleDisplayMode(.inline)
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

    private func confirmAndSignOut() {
        Task { await viewModel.signOut() }
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
}

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(
            authService: MockAuthService(),
            onSignOut: {}
        )
    )
}
