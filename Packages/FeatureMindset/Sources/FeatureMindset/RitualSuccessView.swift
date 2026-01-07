//
//  RitualSuccessView.swift
//  FeatureMindset
//
//  Created by patrick ridd on 1/6/26.
//

import SwiftUI

struct RitualSuccessView: View {
    let archetype: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // The Persona Card
            VStack(spacing: 15) {
                Text("TODAY'S IDENTITY")
                    .font(.caption)
                    .fontWeight(.black)
                    .tracking(2)
                    .foregroundStyle(.secondary)
                
                Text(archetype)
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)
                
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20)
            )
            .padding(.horizontal, 30)
            
            Text("Your mindset is calibrated.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("Done") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
