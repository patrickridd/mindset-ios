//
//  DebugToolsView.swift
//  Development
//

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
}

#Preview {
    NavigationStack {
        DebugToolsView(viewModel: DebugToolsViewModel())
            .navigationTitle("Debug Tools")
    }
}
