//
//  SignOutConfirmationSheet.swift
//  FeatureUserProfile
//
//  Created by patrick ridd on 3/1/26.
//

import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

struct SignOutConfirmationSheet: View {
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
                    Text(FeatureUserProfileStrings.SignOut.confirmationTitle)
                        .font(MindsetFonts.promptHeadline)
                        .foregroundStyle(MindsetColors.textPrimaryAdaptive(for: colorScheme))
                        .multilineTextAlignment(.center)

                    Text(FeatureUserProfileStrings.SignOut.confirmationSubtitle)
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
        let button = Button {
            HapticManager.action()
            dismiss()
            onConfirm()
        } label: {
            Text(SharedLocalizedString.Auth.signOut)
                .font(MindsetFonts.button)
                .foregroundStyle(MindsetColors.accentCoral)
                .frame(maxWidth: .infinity)
                .frame(height: MindsetLayout.buttonHeight)
        }

        if #available(iOS 26, *) {
            button
                .glassEffect(
                    .regular.tint(MindsetColors.accentCoral.opacity(0.15)).interactive(),
                    in: .rect(cornerRadius: MindsetLayout.radiusButton)
                )
        } else {
            button
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
