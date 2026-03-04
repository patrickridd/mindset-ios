//
//  DebugToolsView.swift
//  Development
//

import Domain
import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

public struct DebugToolsView: View {
    @Bindable var viewModel: DebugToolsViewModel
    @Environment(\.colorScheme) private var colorScheme

    public init(viewModel: DebugToolsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body Composition

    public var body: some View {
        ZStack {
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: MindsetLayout.spacing24) {
                    servicesSection
                    subscriptionSection
                    onboardingSection
                    Spacer()
                }
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                .padding(.top, MindsetLayout.spacing30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(DevelopmentStrings.DebugTools.restartingApp, isPresented: $viewModel.showRestartAlert) {
            Button(role: .cancel) {
                HapticManager.action()
                viewModel.restartApp()
            } label: {
                Text(SharedLocalizedString.ok)
            }
        } message: {
            Text(viewModel.environmentDescription)
        }
    }
}

// MARK: - Subviews

private extension DebugToolsView {
    var servicesSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(DevelopmentStrings.DebugTools.sectionHeader)
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .padding(.horizontal, MindsetLayout.paddingMedium)

            VStack(spacing: 0) {
                Toggle(DevelopmentStrings.DebugTools.useMockServices, isOn: $viewModel.useMocks)
                    .font(MindsetFonts.bodyMedium)
                    .tint(MindsetColors.accentOrange)
                    .padding(MindsetLayout.paddingMedium)
            }
            .mindsetCard()
        }
    }

    var onboardingSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(DevelopmentStrings.DebugTools.sectionHeaderOnboarding)
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .padding(.horizontal, MindsetLayout.paddingMedium)

            VStack(spacing: 0) {
                Toggle(DevelopmentStrings.DebugTools.onboardingOverrideToggle, isOn: $viewModel.onboardingOverrideEnabled)
                    .font(MindsetFonts.bodyMedium)
                    .tint(.green)
                    .padding(MindsetLayout.paddingMedium)

                if viewModel.onboardingOverrideEnabled {
                    Divider()
                        .padding(.horizontal, MindsetLayout.paddingMedium)

                    Toggle(DevelopmentStrings.DebugTools.onboardingOverrideValue, isOn: $viewModel.onboardingOverrideValue)
                        .font(MindsetFonts.bodyMedium)
                        .tint(MindsetColors.accentOrange)
                        .padding(MindsetLayout.paddingMedium)
                }
            }
            .mindsetCard()
            .animation(.easeInOut(duration: 0.2), value: viewModel.onboardingOverrideEnabled)

            Text(DevelopmentStrings.DebugTools.onboardingAppliesNextLaunch)
                .font(MindsetFonts.caption)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .padding(.horizontal, MindsetLayout.paddingMedium)
        }
    }

    var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing12) {
            Text(DevelopmentStrings.DebugTools.sectionHeaderSubscription)
                .font(MindsetFonts.sectionHeader)
                .foregroundStyle(MindsetColors.textSecondaryAdaptive(for: colorScheme))
                .padding(.horizontal, MindsetLayout.paddingMedium)

            VStack(spacing: 0) {
                Toggle(DevelopmentStrings.DebugTools.isProOverrideToggle, isOn: $viewModel.isProOverrideEnabled)
                    .font(MindsetFonts.bodyMedium)
                    .tint(.green)
                    .padding(MindsetLayout.paddingMedium)

                if viewModel.isProOverrideEnabled {
                    Divider()
                        .padding(.horizontal, MindsetLayout.paddingMedium)

                    Toggle(DevelopmentStrings.DebugTools.isProOverrideValue, isOn: $viewModel.isProOverrideValue)
                        .font(MindsetFonts.bodyMedium)
                        .tint(MindsetColors.accentOrange)
                        .padding(MindsetLayout.paddingMedium)
                }
            }
            .mindsetCard()
            .animation(.easeInOut(duration: 0.2), value: viewModel.isProOverrideEnabled)
        }
    }
}

#Preview {
    NavigationStack {
        DebugToolsView(viewModel: DebugToolsViewModel())
            .navigationTitle("Debug Tools")
    }
}
