//
//  SignInView.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import AuthenticationServices
import Domain
import SharedLocalization
import SharedUI
import SharedUtils
import SwiftUI

public struct SignInView: View {
    @State private var viewModel: SignInViewModel
    @Environment(\.colorScheme) private var colorScheme

    public init(viewModel: SignInViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body Composition

    public var body: some View {
        Group {
            if viewModel.embedInNavigationStack {
                NavigationStack {
                    signInContent
                }
            } else {
                signInContent
            }
        }
    }
}

// MARK: - Subviews

private extension SignInView {
    var signInContent: some View {
        ZStack {
            BackgroundLinearGradientView()

            ScrollView {
                VStack(spacing: MindsetLayout.spacing12) {
                    heroSection
                    titleSection
                    benefitsSection
                    buttonsSection
                    termsOfServiceSection
                }
            }
            .scrollIndicators(.hidden)
            .toolbar(.hidden, for: .tabBar)

            if viewModel.isLoading {
                loadingOverlay
            }

            if let errorMessage = viewModel.errorMessage {
                errorAlert(message: errorMessage)
            }
        }
        .toolbar {
            if viewModel.embedInNavigationStack {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .cancel) {
                        HapticManager.selection()
                        Task {
                            await viewModel.dismissButtonTapped()
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    var heroSection: some View {
        ZStack {
            Circle()
                .fill(MindsetColors.accentOrange.opacity(0.15))
                .frame(
                    width: MindsetLayout.heroCircleSize,
                    height: MindsetLayout.heroCircleSize
                )
                .blur(radius: MindsetLayout.glowBlurRadius)

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(MindsetColors.accentOrange)
        }
    }

    var titleSection: some View {
        VStack(spacing: MindsetLayout.spacing12) {
            Text(FeatureAuthStrings.profileReadyTitle)
                .font(MindsetFonts.displayHeadline)
                .foregroundStyle(MindsetColors.textPrimaryDark)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)

            Text(FeatureAuthStrings.signInSubtitle)
                .font(MindsetFonts.body)
                .foregroundStyle(MindsetColors.textSecondaryDark)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
        }
    }

    var benefitsSection: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing16) {
            benefitRow(icon: "checkmark.shield.fill", text: FeatureAuthStrings.Benefits.secureAuth)
            benefitRow(icon: "icloud.fill", text: FeatureAuthStrings.Benefits.syncDevices)
            benefitRow(
                icon: "chart.line.uptrend.xyaxis",
                text: FeatureAuthStrings.Benefits.keepStreak
            )
        }
        .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
        .padding(.vertical, MindsetLayout.spacing30)
    }

    var termsOfServiceSection: some View {
        Text(viewModel.termsOfService)
            .lineSpacing(MindsetLayout.spacing4) // Adds space between lines
            .multilineTextAlignment(.center)
            .font(MindsetFonts.caption)
            .foregroundStyle(MindsetColors.textPrimaryDark)
            .padding(.vertical, MindsetLayout.spacing30)
    }

    var buttonsSection: some View {
        VStack(spacing: MindsetLayout.spacing12) {
            SignInWithAppleButton(
                onRequest: { request in
                    viewModel.handleSignInRequest(request)
                },
                onCompletion: { result in
                    Task {
                        await viewModel.handleSignInCompletion(result)
                    }
                }
            )
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: MindsetLayout.buttonHeight)
            .clipShape(RoundedRectangle(cornerRadius: MindsetLayout.radiusButton))
            .disabled(viewModel.isLoading)

            SignInButton(
                icon: "g.circle.fill",
                imageName: "GoogleLogo",
                title: FeatureAuthStrings.signInWithGoogle,
                action: { await viewModel.signInWithGoogle() }
            )
            .disabled(viewModel.isLoading)

            SignInButton(
                icon: "phone.circle.fill",
                iconColor: .green,
                title: FeatureAuthStrings.signInWithPhone,
                isLoading: Binding(
                    get: { viewModel.isLoading },
                    set: { viewModel.isLoading = $0 }
                ),
                action: {
                    viewModel.onPhoneSignInButtonTapped()
                }
            )
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
    }

    func benefitRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: MindsetLayout.spacing12) {
            Image(systemName: icon)
                .font(MindsetFonts.callout)
                .foregroundStyle(MindsetColors.successEmerald)
                .frame(width: MindsetLayout.iconSmall)

            Text(text)
                .font(MindsetFonts.bodyMedium)
                .foregroundStyle(MindsetColors.textPrimaryDark)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: MindsetLayout.spacing20) {
                ProgressView()
                    .tint(MindsetColors.accentOrange)
                    .scaleEffect(1.5)

                Text(viewModel.loadingMessage)
                    .font(MindsetFonts.button)
                    .foregroundStyle(MindsetColors.textPrimaryDark)
            }
            .padding(MindsetLayout.paddingCard)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                    .fill(MindsetColors.backgroundDarkSoft)
            )
        }
    }

    func errorAlert(message: String) -> some View {
        VStack {
            Spacer()

            VStack(spacing: MindsetLayout.spacing16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(MindsetColors.accentCoral)

                Text(FeatureAuthStrings.Error.signInErrorTitle)
                    .font(MindsetFonts.featureTitle)
                    .foregroundStyle(MindsetColors.textPrimaryDark)

                Text(message)
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.textSecondaryDark)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)

                Button {
                    HapticManager.action()
                    viewModel.dismissError()
                } label: {
                    Text(SharedLocalizedString.Error.tryAgain)
                        .font(MindsetFonts.button)
                        .foregroundStyle(MindsetColors.textOnAccent(for: colorScheme))
                        .frame(maxWidth: .infinity)
                        .frame(height: MindsetLayout.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: MindsetLayout.radiusButton)
                                .fill(MindsetColors.accentOrange)
                        )
                }
            }
            .padding(MindsetLayout.paddingCard)
            .background(
                RoundedRectangle(cornerRadius: MindsetLayout.radiusCard)
                    .fill(MindsetColors.backgroundDarkSoft)
            )
            .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)

            Spacer()
        }
        .background(Color.black.opacity(0.6))
    }
}

#Preview {
    let mockAuth = MockAuthService()
    let viewModel = SignInViewModel(
        signInOrLinkUseCase: SignInOrLinkUseCase(
            authService: mockAuth,
            userRepository: MockUserRepository()
        ),
        appleSignInCredentialBuilder: AppleSignInCredentialBuilder(
            nonceStorage: AppleSignInNonceStorage()),
        googleSignInCredentialProvider: MockGoogleSignInCredentialProvider(),
        phoneVerificationProvider: MockPhoneVerificationProvider(),
        logger: DebugLogger.shared,
        onPhoneSignInButtonTapped: {},
        onSignInSuccess: { _ in },
        onSkip: {}
    )
    SignInView(viewModel: viewModel)
}
