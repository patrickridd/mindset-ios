//
//  DebugWrapper.swift
//  Development
//
//  Created by patrick ridd on 3/1/26.
//

import SwiftUI

public struct DebugWrapper: ViewModifier {
    
    public init() {}

    public func body(content: Content) -> some View {
        #if DEBUG
        content
            .withDebugOverlay()
            .withEnvWatermark()
        #else
        content
        #endif
    }
}
