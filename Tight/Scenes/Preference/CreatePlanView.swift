//
//  CreatePlanView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI
import SwiftData

struct CreatePlanView: View {
    @State private var planName: String = ""
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizationProvider.planName.nameKey)
                    .font(.subheadline)
                    .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                    .padding(.horizontal)
                
                PlanNameTextfieldView(name: $planName).horizontalSpacing(.leading)
                CreateButtonView().horizontalSpacing(.leading)
                    .padding(.horizontal)
                    .padding(.top, 16)
            }
            .veriticalSpacing(.bottom)
            .navigationTitle(LocalizationProvider.newPlan.nameKey)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.themeStyle.theme.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Label(LocalizationProvider.close.nameKey, systemImage: "xmark")
                    }
                    .tint(Color.themeStyle.theme.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    func TagsTextFieldView() -> some View {
        Form {
            Text(LocalizationProvider.tags.nameKey)
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                        
            TextField(LocalizationProvider.startAddingExerciseToPlan.nameKey, text: $planName)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
        }

    }
    
    @ViewBuilder
    func CreateButtonView() -> some View {
        Button(action: {
            /// Save schedule exercise
            let plan = Plan(name: planName,
                            startDate: .init(),
                            endDate: nil,
                            repeats: [],
                            duration: 0,
                            updatedDate: .init(),
                            createdDate: .init(),
                            tags: [],
                            isPreset: true)
            
            context.insert(plan)
            dismiss()
        }) {
            Text(LocalizationProvider.create.nameKey)
                .font(.title3)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .horizontalSpacing(.center)
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .background(Color.themeStyle.theme.accent, in: .rect(cornerRadius: 10))
        }
        .disabled(planName.isEmpty)
        .opacity(planName.isEmpty ? 0.5 : 1)
    }
}

#Preview {
    CreatePlanView()
}
