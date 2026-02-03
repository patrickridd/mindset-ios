//
//  SignInView.swift
//  FeatureAuth
//
//  Created by Mindset Team on 2/1/26.
//

import SwiftUI
import AuthenticationServices
import SharedUI
import SharedUtils
import Domain

public struct SignInView: View {
#if DEBUG
    @ObserveInjection var inject
#endif
    
    @State private var viewModel: SignInViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    public init(viewModel: SignInViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient(
                colors: [
                    MindsetColors.backgroundDark,
                    MindsetColors.backgroundDarkSoft,
                    MindsetColors.backgroundWarmAccent.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: MindsetLayout.spacing12) {
                    // Top spacing
                    Color.clear.frame(height: MindsetLayout.spacing8)
                    
                    // Hero Icon
                    ZStack {
                        Circle()
                            .fill(MindsetColors.accentOrange.opacity(0.15))
                            .frame(width: MindsetLayout.heroCircleSize, height: MindsetLayout.heroCircleSize)
                            .blur(radius: MindsetLayout.glowBlurRadius)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(MindsetColors.accentOrange)
                    }
                    .padding(.bottom, MindsetLayout.spacing20)
                    
                    // Title
                    Text("Your Mindset Profile is Ready")
                        .font(MindsetFonts.displayHeadline)
                        .foregroundStyle(MindsetColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                    
                    // Subtitle
                    Text("Sign in to save your progress and sync across devices")
                        .font(MindsetFonts.body)
                        .foregroundStyle(MindsetColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                    
                    // Benefits List
                    VStack(alignment: .leading, spacing: MindsetLayout.spacing16) {
                        benefitRow(icon: "checkmark.shield.fill", text: "Secure & private authentication")
                        benefitRow(icon: "icloud.fill", text: "Sync across all your devices")
                        benefitRow(icon: "chart.line.uptrend.xyaxis", text: "Never lose your streak or progress")
                    }
                    .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                    .padding(.vertical, MindsetLayout.spacing30)
                    
                    // Sign in with Apple Button
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
                    .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                    .disabled(viewModel.isSigningIn)
                    
                    // Google Sign In Button
                    GoogleSignInButton { idToken, accessToken in
                        Task {
                            await viewModel.signInWithGoogle(
                                idToken: idToken,
                                accessToken: accessToken
                            )
                        }
                    }
                    .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                    .disabled(viewModel.isSigningIn)
                    
                    // OR divider
                    HStack(spacing: MindsetLayout.spacing8) {
                        Rectangle()
                            .fill(MindsetColors.borderSubtle)
                            .frame(height: 1)
                        
                        Text("OR")
                            .font(MindsetFonts.caption)
                            .foregroundStyle(MindsetColors.textMuted)
                        
                        Rectangle()
                            .fill(MindsetColors.borderSubtle)
                            .frame(height: 1)
                    }
                    .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                    
                    // Continue without account (optional)
                    Button {
                        HapticManager.selection()
                        Task {
                            await viewModel.continueWithoutAccount()
                        }
                    } label: {
                        Text("Continue without account")
                            .font(MindsetFonts.button)
                            .foregroundStyle(MindsetColors.textSecondary)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, MindsetLayout.paddingMedium)
                    }
                    .disabled(viewModel.isSigningIn)
                    
                    // Bottom spacing
                    Color.clear.frame(height: MindsetLayout.spacing30)
                }
            }
            .scrollIndicators(.hidden)
            
            // Loading overlay
            if viewModel.isSigningIn {
                loadingOverlay
            }
            
            // Error alert
            if let errorMessage = viewModel.errorMessage {
                errorAlert(message: errorMessage)
            }
        }
#if DEBUG
        .enableInjection()
#endif
    }
    
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: MindsetLayout.spacing12) {
            Image(systemName: icon)
                .font(MindsetFonts.callout)
                .foregroundStyle(MindsetColors.successEmerald)
                .frame(width: MindsetLayout.iconSmall)
            
            Text(text)
                .font(MindsetFonts.bodyMedium)
                .foregroundStyle(MindsetColors.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: MindsetLayout.spacing20) {
                ProgressView()
                    .tint(MindsetColors.accentOrange)
                    .scaleEffect(1.5)
                
                Text("Signing you in...")
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
    
    private func errorAlert(message: String) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: MindsetLayout.spacing16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(MindsetColors.accentCoral)
                
                Text("Sign In Error")
                    .font(MindsetFonts.featureTitle)
                    .foregroundStyle(MindsetColors.textPrimary)
                
                Text(message)
                    .font(MindsetFonts.body)
                    .foregroundStyle(MindsetColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Button {
                    HapticManager.action()
                    viewModel.dismissError()
                } label: {
                    Text("Try Again")
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
    let mockAuthService = MockAuthService()
    let viewModel = SignInViewModel(
        authService: mockAuthService,
        onSignInSuccess: { _ in },
        onSkip: {}
    )
    return SignInView(viewModel: viewModel)
}
