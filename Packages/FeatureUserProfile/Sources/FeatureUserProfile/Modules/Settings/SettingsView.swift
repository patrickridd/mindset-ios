//
//  SettingsView.swift
//  FeatureUserProfile
//
//  Created by patrick ridd on 3/3/26.
//

import SwiftUI

public struct SettingsView: View {
    
    @Bindable private var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Text("Settings")
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
