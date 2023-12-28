//
//  EditPlanView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/27.
//

import SwiftUI
import SwiftData

struct EditPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var plan: Plan
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {
                PlanNameTextfieldView(name: $plan.name)
                    .horizontalSpacing(.leading)
            }
            .padding()
            .veriticalSpacing(.bottom)
            .navigationTitle("Edit Plan")
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                        
            TextField("New Plan", text: $plan.name)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))

        }
    }
}

struct PlanNameTextfieldView: View {
    @Binding var name: String
    @FocusState private var isFocused
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            TextField("e.g. lower body, burn weight..", text: $name)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                .background(Color.themeStyle.theme.background)
                .cornerRadius(10)
                .focused($isFocused)
                .autocorrectionDisabled()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.isFocused = true
                    }
                }
        }
    }
}

#Preview {
    EditPlanView(plan: .init(name: "", arrangedExercises: [], startDate: .init(), endDate: .init(), repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: true))
}
