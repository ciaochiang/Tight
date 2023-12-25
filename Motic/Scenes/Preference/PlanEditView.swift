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
    @State private var exercises: [ArrangedExercise]
    @State private var exerciseToEdit: ArrangedExercise?
    
    init(plan: Plan) {
        self.plan = plan
        _exercises = .init(wrappedValue: plan.arrangedExercises.sorted { $0.order < $1.order })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArrangedExercisesListView()
        }
        .background(Color.themeStyle.theme.background)
        .veriticalSpacing(.top)
        .navigationTitle(plan.name)
        .sheet(isPresented: $isAdding, content: {
            CreateArrangedExerciseView(plan: plan, incrementalOrderNumber: plan.arrangedExercises.count, completion: { _ in
                exercises = plan.arrangedExercises
            })
                .presentationDetents([.height(400)])
                .presentationCornerRadius(30)
        })
//        .sheet(item: $exerciseToEdit) { $exercise in
//            EditArrangedExerciseView(arrangedExercise: $exercise)
//                .presentationDetents([.height(300)])
//                .presentationCornerRadius(30)
//        }
        .toolbar {
            Button(action: {
                isAdding.toggle()
            }) {
                Label("Add", systemImage: "plus")
            }
        }
    }
    
    @ViewBuilder
    func ArrangedExercisesListView() -> some View {
        List {
            ForEach($exercises, id: \.self) { $exercise in
                ArrangedExerciseCard(exercise: $exercise)
                    .veriticalSpacing(.center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            /// Delete items
                            withAnimation {
                                if let index = plan.arrangedExercises.firstIndex(where: { $0 == exercise }) {
                                    plan.arrangedExercises.remove(at: index)
                                }
                                exercises = plan.arrangedExercises.sorted { $0.order < $1.order }
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
            .onMove(perform: { indexSet, newOffset in
                exercises.move(fromOffsets: indexSet, toOffset: newOffset)
                
                /// Update all order number
                updateOrderNumbers()
            })
        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .background(Color.themeStyle.theme.background)

    }
    
    func updateOrderNumbers() {
        for i in 0..<exercises.count {
            let exercise = exercises[i]
            exercise.order = i
        }
        
        plan.arrangedExercises = exercises
    }
}
