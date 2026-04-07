//
//  Extension+PromptType.swift
//  SharedUI
//
//  Created by patrick ridd on 4/6/26.
//

import Domain
import SwiftUI

public extension PromptType {
    var themeColor: Color {
        switch self {
        case .morning: return .orange
        case .evening: return .indigo
        case .anytime: return .mint
        case .deepWork: return .purple
        }
    }

    // You can also map specific gradients or Lottie files here
    var backgroundGradient: Gradient {
        switch self {
        case .morning: return Gradient(colors: [.orange, .yellow])
        case .evening: return Gradient(colors: [.indigo, .black])
        default: return Gradient(colors: [.gray])
        }
    }
}
