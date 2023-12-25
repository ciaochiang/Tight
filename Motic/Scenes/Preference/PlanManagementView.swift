//
//  PlanManagementView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/24.
//

import SwiftUI
import SwiftData

struct PlanManagementView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Query(filter: #Predicate<Plan> { $0.isPreset == true }, sort: \.createdDate) var plans: [Plan]
    @State private var isAdding: Bool = false
    @State private var planToEdit: Plan?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PlansListView()
        }
        .background(Color.themeStyle.theme.background)
        .veriticalSpacing(.top)
        .navigationTitle("Plans")
        .sheet(isPresented: $isAdding, content: {
            CreatePlanView()
                .presentationDetents([.height(200)])
                .presentationCornerRadius(30)

        })
        .toolbar {
            Button(action: {
                isAdding.toggle()
            }) {
                Label("Add", systemImage: "plus")
            }
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text("Plans").foregroundStyle(Color.themeStyle.theme.accent)
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
                            Label("Delete", systemImage: "trash")
                                .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        }
                        .tint(Color.themeStyle.theme.accent)
                    }
                    .background(
                        NavigationLink("", destination: EditPlanPresetView(plan: plan)).opacity(0)
                    )
            }
        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .background(Color.themeStyle.theme.background)
    }
}

#Preview {
    let previewContainer = PreviewContainer([Plan.self])
    return PlanManagementView().modelContainer(previewContainer.container)
}
