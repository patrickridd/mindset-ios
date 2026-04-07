//
//  MultiSlotPromptQuestionView.swift
//  FeatureMindset
//
//  Created by patrick ridd on 4/5/26.
//

import Domain
import SharedUI
import SwiftUI

struct MultiSlotPromptQuestionView: View {
    @Bindable var viewModel: MindsetPracticeFlowViewModel
    let prompt: Prompt
    let isTextFieldFocused: FocusState<Bool>.Binding
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: MindsetLayout.spacing20) {
            // The Question Header
            VStack(alignment: .leading, spacing: MindsetLayout.spacing8) {
                Text(prompt.headline)
                    .font(MindsetFonts.sectionHeader)
                Text(prompt.questionText)
                    .font(MindsetFonts.body)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, MindsetLayout.spacing8)

            // The Interactive Slots
            VStack(spacing: MindsetLayout.spacing12) {
                ForEach(0..<prompt.responseSlotCount, id: \.self) { index in
                    let isActive = viewModel.currentSlotIndex == index
                    let isCompleted = index < viewModel.currentSlotIndex
                    let answer = viewModel.answers[prompt.id]?[index] ?? ""

                    GratitudeSlotView(
                        index: index,
                        text: isActive ? viewModel.currentInputText : answer,
                        isActive: isActive,
                        isCompleted: isCompleted
                    )
                    .onTapGesture {
                        withAnimation(.snappy) {
                            viewModel.currentSlotIndex = index
                            isTextFieldFocused.wrappedValue = true
                        }
                    }
                }
            }

            // The Invisible Input Engine
            TextField("", text: $viewModel.currentInputText)
                .focused(isTextFieldFocused)
                .opacity(0)
                .frame(height: 0)
            
            // The "Scientific Rationale" Reveal
            if viewModel.currentSlotIndex > 0 {
                scientificRationaleLabel
            }
        }
    }

    private var scientificRationaleLabel: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.stars.fill")
                .foregroundStyle(MindsetColors.accentOrange)
            Text(prompt.scientificRationale)
                .font(MindsetFonts.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(MindsetColors.accentOrange.opacity(0.05))
        .cornerRadius(MindsetLayout.radiusCard)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
