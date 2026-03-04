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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var measuredContentHeight: CGFloat = MindsetLayout.detentSmall
    @State private var availableHeight: CGFloat = 0

    var body: some View {
        ZStack {
            MindsetColors.backgroundGrouped(for: colorScheme)
                .opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                content
                    .readHeight { newHeight in
                        let clamped = clampDetentHeight(newHeight)
                        guard abs(clamped - measuredContentHeight) > 1 else { return }
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            measuredContentHeight = clamped
                        }
                    }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .readAvailableHeight { height in
            guard height > 0 else { return }
            availableHeight = height
            measuredContentHeight = clampDetentHeight(measuredContentHeight)
        }
        .presentationDetents(detents)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(MindsetLayout.radiusCardLarge)
    }

    private var detents: Set<PresentationDetent> {
        if dynamicTypeSize.isAccessibilitySize {
            return [.large]
        }
        return [
            .height(measuredContentHeight),
            .large
        ]
    }

    private var detentMaxHeight: CGFloat {
        let maxCandidate = availableHeight > 0
            ? (availableHeight - MindsetLayout.spacing40)
            : (MindsetLayout.detentSmall + MindsetLayout.spacing40)
        return max(MindsetLayout.detentSmall, maxCandidate)
    }

    private func clampDetentHeight(_ height: CGFloat) -> CGFloat {
        min(max(height, MindsetLayout.detentSmall), detentMaxHeight)
    }

    private var content: some View {
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

// MARK: - Measurement

private struct ConfirmationSheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct AvailableHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private extension View {
    func readHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ConfirmationSheetHeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(ConfirmationSheetHeightKey.self) { height in
            guard height > 0 else { return }
            onChange(height)
        }
    }

    func readAvailableHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: AvailableHeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(AvailableHeightKey.self) { height in
            guard height > 0 else { return }
            onChange(height)
        }
    }

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

// MARK: - Previews

private struct ConfirmationSheetPreviewHost: View {
    let sheet: AnyView

    @State private var isPresented = true

    var body: some View {
        ZStack {
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()
            Text("Preview Host")
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
        }
        .sheet(isPresented: $isPresented) {
            sheet
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

#Preview("Sheet - Sign Out") {
    ConfirmationSheetPreviewHost(
        sheet: AnyView(SignOutConfirmationSheet(onConfirm: {}, onCancel: {}))
    )
}

#Preview("Sheet - Delete Account") {
    ConfirmationSheetPreviewHost(
        sheet: AnyView(
            ConfirmationSheet(
                title: FeatureUserProfileStrings.DeleteAccount.confirmationTitle,
                subtitle: FeatureUserProfileStrings.DeleteAccount.confirmationSubtitle,
                confirmTitle: FeatureUserProfileStrings.DeleteAccount.confirmButton,
                confirmStyle: .destructive,
                onConfirm: {},
                onCancel: {}
            )
        )
    )
}

#Preview("Sheet - Long text (AX3)") {
    ConfirmationSheetPreviewHost(
        sheet: AnyView(
            ConfirmationSheet(
                title: "Delete account?",
                subtitle: """
This permanently deletes your account, clears all local data on this device, and may require you to sign in again if Firebase needs recent authentication. You can’t undo this.
""",
                confirmTitle: "Delete Account",
                confirmStyle: .destructive,
                onConfirm: {},
                onCancel: {}
            )
        )
    )
    .dynamicTypeSize(.accessibility3)
}
