//
//  ConfirmationSheet.swift
//  FeatureUserProfile
//
//  Created by patrick ridd on 3/1/26.
//

import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

enum ConfirmationSheetConfirmStyle {
    case standard
    case destructive
}

struct ConfirmationSheet: View {
    let title: String
    let subtitle: String
    let confirmTitle: String
    let confirmStyle: ConfirmationSheetConfirmStyle
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            MindsetColors.backgroundGrouped(for: colorScheme)
                .opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: MindsetLayout.spacing24) {
                VStack(spacing: MindsetLayout.spacing8) {
                    Text(title)
                        .font(MindsetFonts.promptHeadline)
                        .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(MindsetFonts.caption)
                        .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: MindsetLayout.spacing12) {
                    confirmButton
                    cancelButton
                }
            }
            .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
            .padding(.vertical, MindsetLayout.paddingXLarge)
            .padding(.top, MindsetLayout.spacing40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    @ViewBuilder
    private var confirmButton: some View {
        Button {
            HapticManager.action()
            dismiss()
            onConfirm()
        } label: {
            Text(confirmTitle)
                .font(MindsetFonts.button)
                .foregroundStyle(MindsetColors.accentCoral)
                .frame(maxWidth: .infinity)
                .frame(height: MindsetLayout.buttonHeight)
        }
        .confirmationSheetConfirmStyle(confirmStyle)
    }

    private var cancelButton: some View {
        Button {
            HapticManager.selection()
            dismiss()
            onCancel()
        } label: {
            Text(SharedLocalizedString.cancel)
                .font(MindsetFonts.bodyMedium)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .frame(maxWidth: .infinity)
                .frame(height: MindsetLayout.spacing40)
        }
    }
}

private extension View {
    @ViewBuilder
    func confirmationSheetConfirmStyle(_ style: ConfirmationSheetConfirmStyle) -> some View {
        switch style {
        case .standard:
            self.mindsetButton()
        case .destructive:
            self.mindsetDestructiveButton()
        }
    }
}

struct SignOutConfirmationSheet: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ConfirmationSheet(
            title: FeatureUserProfileStrings.SignOut.confirmationTitle,
            subtitle: FeatureUserProfileStrings.SignOut.confirmationSubtitle,
            confirmTitle: SharedLocalizedString.Auth.signOut,
            confirmStyle: .standard,
            onConfirm: onConfirm,
            onCancel: onCancel
        )
    }
}

#Preview("Sign Out") {
    SignOutConfirmationSheet(onConfirm: {} , onCancel: {})
}

#Preview("Delete Account") {
    ConfirmationSheet(
        title: FeatureUserProfileStrings.DeleteAccount.confirmationTitle,
        subtitle: FeatureUserProfileStrings.DeleteAccount.confirmationSubtitle,
        confirmTitle: FeatureUserProfileStrings.DeleteAccount.confirmButton,
        confirmStyle: .destructive,
        onConfirm: {},
        onCancel: {}
    )
}
