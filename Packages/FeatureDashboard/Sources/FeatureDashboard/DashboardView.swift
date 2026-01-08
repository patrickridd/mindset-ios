//
//  DashboardView.swift
//  FeatureDashboard
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI

public struct DashboardView: View {
    // In a real app, this would come from a ViewModel fetching from Supabase
    @State private var streakCount = 5
    @State private var currentArchetype = "The Architect"
    
    var onStartRitual: () -> Void // The Coordinator will handle this transition
    
    public init(onStartRitual: @escaping () -> Void) {
        self.onStartRitual = onStartRitual
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    headerSection
                    
                    // Identity Card (The "Hook")
                    identityCard
                    
                    // Stats Grid
                    statsGrid
                    
                    Spacer(minLength: 40)
                    
                    // Main Action
                    Button(action: onStartRitual) {
                        HStack {
                            Text("Begin Morning Ritual")
                            Image(systemName: "sparkles")
                        }
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Capsule().fill(Color.orange))
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Mindset")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading) {
            Text("Good Morning,")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Ready to Calibrate?")
                .font(.largeTitle.bold())
        }
    }
    
    private var identityCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("CURRENT IDENTITY")
                .font(.caption2.bold())
                .tracking(1)
                .foregroundStyle(.white.opacity(0.7))
            
            Text(currentArchetype)
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text("Your focus on structure and goals yesterday has aligned you with the Architect archetype.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
    }
    
    private var statsGrid: some View {
        HStack {
            statBox(title: "Streak", value: "\(streakCount) Days", icon: "flame.fill", color: .orange)
            statBox(title: "Rituals", value: "12 Total", icon: "checkmark.circle.fill", color: .green)
        }
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
