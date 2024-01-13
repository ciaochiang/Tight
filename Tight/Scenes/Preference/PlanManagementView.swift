//
//  PlanManagementView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/24.
//

import SwiftUI
import SwiftData

struct PlanManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context: ModelContext
    @Query(filter: #Predicate<Plan> { $0.isPreset == true }, sort: \.createdDate) var plans: [Plan]
    @State private var isAdding: Bool = false
    @State private var planToEdit: Plan?
    
    var isImporting: Bool = false
    var onSelected: ((Plan) -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                if isImporting {
                    SelectablePlansListView()
                } else {
                    if plans.isEmpty {
                        PlaceholderView()
                            .veriticalSpacing(.center)
                            .offset(y: -32)
                    } else {
                        PlansListView()
                    }
                }
            }
            .background(Color.themeStyle.theme.background)
            .veriticalSpacing(.top)
            .navigationTitle(LocalizationProvider.plans.nameKey)
            .navigationBarTitleDisplayMode(isImporting ? .inline : .automatic)
            .sheet(isPresented: $isAdding, content: {
                CreatePlanView()
                    .presentationDetents([.height(200)])
                    .presentationCornerRadius(16)

            })
            .sheet(item: $planToEdit) { plan in
                EditPlanView(plan: plan)
                    .presentationDetents([.height(120)])
                    .presentationCornerRadius(16)
            }
            .toolbar {
                if isImporting {
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
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(LocalizationProvider.plans.nameKey).foregroundStyle(Color.themeStyle.theme.accent)
            }
            .font(.title.bold())
            .frame(height: 90)
        }
        .padding(.horizontal, 16)
        .background(Color.themeStyle.theme.background)
        .horizontalSpacing(.leading)
    }
    
    @ViewBuilder
    func PlansListView() -> some View {
        List {
            ForEach(plans, id: \.self) { plan in
                PlanCard(plan: plan)
                    .veriticalSpacing(.center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            /// Delete items
                            withAnimation {
                                context.delete(plan)
                            }
                        }) {
                            Image(systemName: "trash")
                                .symbolVariant(.fill)
                        }
                        .tint(Color.themeStyle.theme.accent)
                        
                        Button(action: {
                            planToEdit = plan
                        }) {
                            Image(systemName: "pencil")
                                .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        }
                    }
                    .background(
                        NavigationLink("", destination: EditPlanPresetView(plan: plan)).opacity(0)
                    )
            }
        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .background(Color.themeStyle.theme.background)
        .toolbar {
            Button(action: {
                isAdding.toggle()
            }) {
                Label(LocalizationProvider.add.nameKey, systemImage: "plus")
            }
        }
    }
    
    @ViewBuilder
    func SelectablePlansListView() -> some View {
        List {
            ForEach(plans, id: \.self) { plan in
                PlanCard(plan: plan)
                    .veriticalSpacing(.center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .onTapGesture {
                        /// Callback
                        onSelected?(plan)
                        dismiss()
                    }
            }
        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .background(Color.themeStyle.theme.background)
    }
    
    @ViewBuilder
    func PlaceholderView() -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(LocalizationProvider.noPlans.nameKey)
                .font(.title2)
                .fontWeight(.bold)
            Text(LocalizationProvider.startCreatingNewPlan.nameKey)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            
            Button(action: {
                isAdding.toggle()
            }) {
                Text(LocalizationProvider.createNewPlan.nameKey)
                    .background(Color.themeStyle.theme.accent)
                    .foregroundColor(Color.themeStyle.theme.white)
                    .horizontalSpacing(.center)
                    .frame(height: 44)
            }
            .background(Color.themeStyle.theme.accent)
            .cornerRadius(8)
            .padding(.horizontal, 64)
            .padding(.top, 16)
        }
        .toolbar {
            Button(action: {
                isAdding.toggle()
            }) {
                Label(LocalizationProvider.add.nameKey, systemImage: "plus")
            }
        }
    }
}

#Preview {
    let previewContainer = PreviewContainer([Plan.self])
    return PlanManagementView().modelContainer(previewContainer.container)
}
