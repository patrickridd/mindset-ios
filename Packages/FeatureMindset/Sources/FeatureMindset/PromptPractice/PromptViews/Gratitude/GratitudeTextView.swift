//
//  GratitudeTextView.swift
//  FeatureMindset
//
//  Created by patrick ridd on 4/5/26.
//

import SwiftUI

struct GratitudeTextView: View {
    @State private var text = ""
    var step: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("THING #\(step)")
                .font(.caption2.bold())
                .foregroundColor(.orange)
            
            TextField("I'm grateful for...", text: $text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(text.isEmpty ? Color.clear : Color.orange.opacity(0.5), lineWidth: 2)
                )
        }
        .scaleEffect(text.isEmpty ? 0.95 : 1.0)
        .animation(.spring(), value: text)
    }
}

#Preview {
    GratitudeTextView(step: 1)
}
