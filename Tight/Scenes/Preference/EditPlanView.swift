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
    @State private var tags: [Tag] = []
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                PlanNameTextfieldView(name: $plan.name)
                    .horizontalSpacing(.leading)
            }
            .padding()
            .veriticalSpacing(.bottom)
            .navigationTitle("Edit Plan")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.themeStyle.theme.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Label("Close", systemImage: "xmark")
                    }
                    .tint(Color.themeStyle.theme.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    func TagsTextFieldView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                        
            TagField(tags: $tags, limit: 5)
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
    let previewContainer = PreviewContainer([Tag.self])
    let plan: Plan = .init(name: "", startDate: .init(), endDate: .init(), repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: true)
    return EditPlanView(plan: plan).modelContainer(previewContainer.container)
}
