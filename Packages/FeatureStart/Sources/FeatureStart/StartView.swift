//
//  StartView.swift
//  FeatureStart
//

import Domain
import SharedUI
import SharedUtils
import SwiftUI

public struct StartView: View {
    @Bindable private var viewModel: StartViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var heroPulse = false

    public init(viewModel: StartViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing24) {
            heroSection
            Spacer(minLength: MindsetLayout.spacing40)
            actionSection
        }
        .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
        .padding(.top, MindsetLayout.paddingLarge)
        .padding(.bottom, MindsetLayout.paddingStandard)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            ZStack {
                if !reduceMotion {
                    MindsetAmbientAnimationView(
                        animation: .backgroundLinesWave,
                        speed: 0.4,
                        opacity: 1.0
                    )
                }
                VignetteBackgroundView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }

    // MARK: - Subviews

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing16) {
            Image(systemName: "sparkles")
                .font(.system(size: MindsetLayout.iconLarge))
                .foregroundStyle(MindsetColors.accentOrange)
                .symbolRenderingMode(.hierarchical)
                .scaleEffect(heroPulse ? 1.25 : 1.0)
                .opacity(heroPulse ? 1.0 : 0.78)
                .accessibilityHidden(true)

            Text(FeatureStartStrings.Screen.title)
                .font(MindsetFonts.displayLarge)
                .foregroundStyle(MindsetColors.textPrimaryDark)
                .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2) // <--- The magic line
                .fixedSize(horizontal: false, vertical: true)

            Text(FeatureStartStrings.Screen.subheadline)
                .font(MindsetFonts.body)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2) // <--- The magic line

                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                heroPulse = true
            }
        }
    }

    private var actionSection: some View {
        VStack(spacing: MindsetLayout.spacing30) {
            if let message = viewModel.guestErrorMessage {
                Text(message)
                    .font(MindsetFonts.footnote)
                    .foregroundStyle(MindsetColors.accentCoral)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }

            Button(action: {
                HapticManager.action()
                viewModel.onGetStarted()
            }) {
                HStack {
                    Text(FeatureStartStrings.Actions.getStarted)
                    Image(systemName: "sparkles")
                }
                .font(MindsetFonts.button)
                .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                .frame(maxWidth: .infinity)
                .frame(height: MindsetLayout.buttonHeight)
                .background(
                    ZStack {
                        // The iOS System Orange
                        Capsule().fill(MindsetColors.accentOrange)
                        
                        // A subtle white glow on the top edge
                        LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom)
                    }
                    .cornerRadius(26)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            }

            Button {
                HapticManager.selection()
                viewModel.onAlreadyHaveAccount()
            } label: {
                Text(FeatureStartStrings.Actions.alreadyHaveAccount)
                    .font(MindsetFonts.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(MindsetColors.accentOrange)
                    .frame(maxWidth: .infinity)
                    .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2) // <--- The magic line
                
                
            }
            .buttonStyle(.plain)

            Button {
                HapticManager.selection()
                viewModel.continueAsGuest()
            } label: {
                Group {
                    if viewModel.isGuestLoading {
                        ProgressView()
                            .tint(MindsetColors.textMuted)
                    } else {
                        Text(FeatureStartStrings.Actions.continueAsGuest)
                            .font(MindsetFonts.subheadline)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2) // <--- The magic line
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: MindsetLayout.buttonHeight)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isGuestLoading)
        }
    }
}

#if DEBUG
    #Preview("Start") {
        StartView(
            viewModel: StartViewModel(
                signInService: MockAuthService(),
                userRepository: MockUserRepository(),
                logger: MockAppLogger(),
                onGetStarted: {},
                onAlreadyHaveAccount: {},
                onGuestSignedIn: {}
            )
        )
    }

    private struct MockAppLogger: AppLogger {
        func log(_ message: String) {}
    }
#endif
