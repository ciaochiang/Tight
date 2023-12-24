//
//  PlanEditView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI
import SwiftData

struct PlanEditView: View {
    @Bindable var plan: Plan
    @State private var isAdding: Bool = false
    @State private var exerciseToEdit: DesignedExercise?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PlannedExercisesView()
        }
        .background(Color.themeStyle.theme.background)
        .veriticalSpacing(.top)
        .navigationTitle(plan.name)
        .sheet(isPresented: $isAdding, content: {
            AddPlanView()
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
    func PlannedExercisesView() -> some View {
        List {
            ForEach(plan.exercises, id: \.self) { exercise in
                PlanCard(plan: plan)
                    .veriticalSpacing(.center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            /// Delete items
                            withAnimation {
                                if let index = plan.exercises.firstIndex(where: { $0 == exercise }) {
                                    plan.exercises.remove(at: index)
                                }
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                                .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        }
                        .tint(Color.themeStyle.theme.accent)
                    }
                    .onTapGesture {
                        exerciseToEdit = exercise
                    }
            }
        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .background(Color.themeStyle.theme.background)
    }
}

#Preview {
    PlanEditView(plan: .init(name: "test", tags: [], exercises: [], createdDate: .init()))
}
