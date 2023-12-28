//
//  CreatePlanView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI
import SwiftData

struct CreatePlanView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) private var dismiss
    @State private var planName: String = ""
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {
                PlanNameTextfieldView(name: $planName).horizontalSpacing(.leading)
                CreateButtonView().horizontalSpacing(.leading)
            }
            .padding()
            .veriticalSpacing(.bottom)
            .navigationTitle("New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.themeStyle.theme.background)
            .toolbar {
                Button(action: {
                    dismiss()
                }) {
                    Label("Close", systemImage: "xmark")
                }
                .tint(Color.themeStyle.theme.primary)
            }
        }
    }
    
    @ViewBuilder
    func TagsTextFieldView() -> some View {
        Form {
            Text("Tags")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                        
            TextField("New Plan", text: $planName)
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
                            arrangedExercises: [],
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
            Text("Create")
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
