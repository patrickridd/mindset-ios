//
//  MindsetWebView.swift
//  SharedUI
//
//  Created by Mindset Team on 3/4/26.
//

import Foundation
import SwiftUI
import WebKit

public struct MindsetWebView: View {
    public let url: URL

    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var reloadToken = UUID()

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        ZStack {
            MindsetWKWebView(
                url: url,
                reloadToken: reloadToken,
                isLoading: $isLoading,
                errorMessage: $errorMessage
            )

            if let errorMessage {
                errorState(message: errorMessage)
            } else if isLoading {
                ProgressView()
                    .tint(MindsetColors.accentOrange)
                    .scaleEffect(1.2)
            }
        }
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: MindsetLayout.spacing12) {
            Text(message)
                .font(MindsetFonts.caption)
                .foregroundStyle(MindsetColors.textSecondaryDark)
                .multilineTextAlignment(.center)

            Button("Retry") {
                errorMessage = nil
                reloadToken = UUID()
            }
            .font(MindsetFonts.button)
            .frame(maxWidth: .infinity)
            .frame(height: MindsetLayout.buttonHeight)
            .mindsetButton()
        }
        .padding(MindsetLayout.paddingCard)
        .frame(maxWidth: 420)
    }
}

private struct MindsetWKWebView: UIViewRepresentable {
    let url: URL
    let reloadToken: UUID

    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        context.coordinator.load(url: url, reloadToken: reloadToken, in: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.load(url: url, reloadToken: reloadToken, in: webView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, errorMessage: $errorMessage)
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        private let isLoading: Binding<Bool>
        private let errorMessage: Binding<String?>

        private var lastLoadedURL: URL?
        private var lastReloadToken: UUID?

        init(isLoading: Binding<Bool>, errorMessage: Binding<String?>) {
            self.isLoading = isLoading
            self.errorMessage = errorMessage
        }

        func load(url: URL, reloadToken: UUID, in webView: WKWebView) {
            guard lastLoadedURL != url || lastReloadToken != reloadToken else { return }
            lastLoadedURL = url
            lastReloadToken = reloadToken
            webView.load(URLRequest(url: url))
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            errorMessage.wrappedValue = nil
            isLoading.wrappedValue = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading.wrappedValue = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading.wrappedValue = false
            errorMessage.wrappedValue = error.localizedDescription
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            isLoading.wrappedValue = false
            errorMessage.wrappedValue = error.localizedDescription
        }
    }
}

