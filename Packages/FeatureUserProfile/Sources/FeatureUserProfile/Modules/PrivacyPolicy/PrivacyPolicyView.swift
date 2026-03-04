//
//  PrivacyPolicyView.swift
//  FeatureUserProfile
//
//  Created by Mindset Team on 3/4/26.
//

import Foundation
import SharedUI
import SwiftUI

public struct PrivacyPolicyView: View {
    private let url: URL

    @Environment(\.colorScheme) private var colorScheme

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        ZStack {
            MindsetColors.backgroundGrouped(for: colorScheme)
                .ignoresSafeArea()

            MindsetWebView(url: url)
                .mindsetCard()
                .padding(.horizontal, MindsetLayout.paddingScreenHorizontal)
                .padding(.vertical, MindsetLayout.paddingMedium)
        }
        .navigationTitle(FeatureUserProfileStrings.Legal.privacyPolicyNavTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView(url: URL(string: "https://example.com/privacy")!)
    }
}

