//
//  DashboardView.swift
//  FeatureDashboard
//
//  Created by patrick ridd on 1/7/26.
//

import SwiftUI
import Domain

public struct DashboardView: View {

    @State private var viewModel: DashboardViewModel

        public init(viewModel: DashboardViewModel) {
            // Initialize the ViewModel with the injected service
            self._viewModel = State(initialValue: viewModel)
        }

        public var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        if viewModel.isLoading {
                            ProgressView().padding()
                        } else {
                            headerSection
                            identityCard
                            statsGrid
                            
                            Spacer(minLength: 40)
                            
                            Button(action: viewModel.onStartMindet) {
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
                    }
                    .padding()
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("Mindset")
                .task {
                    await viewModel.loadDashboardData()
                }
            }
        }
        
        private var headerSection: some View {
            VStack(alignment: .leading) {
                Text("Good Morning,")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                // Use the data from Onboarding!
                Text(viewModel.userProfile?.userName ?? "Visionary")
                    .font(.largeTitle.bold())
            }
        }
        
        private var identityCard: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text("CURRENT GOAL")
                    .font(.caption2.bold())
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.7))
                
                Text(viewModel.userProfile?.primaryGoal ?? "Calibrate Your Mindset")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            .padding(25)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
        }
    
    private var statsGrid: some View {
        HStack(spacing: 15) {
            statBox(
                title: "Streak",
                value: "\(viewModel.streakCount) Days",
                icon: "flame.fill",
                // Only light up the flame if they have an active streak
                color: viewModel.streakCount > 0 ? .orange : .secondary
            )
            
            statBox(
                title: "Rituals",
                // Replace hardcoded "12" with the real count from your repository
                value: "\(viewModel.totalRituals) Total",
                icon: "checkmark.circle.fill",
                color: .green
            )
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

#Preview {
    let mindSetReposoitory = MockMindsetRepository(days: 1)
    let viewModel = DashboardViewModel(
        userRepository: MockUserRepository(),
        mindsetRepository: mindSetReposoitory,
        getStreakUseCase: GetStreakUseCase(repository: mindSetReposoitory)
    ) {
        
    }
    return DashboardView(viewModel: viewModel)
}
