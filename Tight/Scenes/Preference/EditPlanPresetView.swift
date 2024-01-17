//
//  PlanEditView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI
import SwiftData

struct EditPlanPresetView: View {
    @Environment(\.modelContext) var context
    @Bindable var plan: Plan
    @State private var isAdding: Bool = false
    @State private var exerciseToEdit: ArrangedExercise?
    @State private var isItemEditable: Bool = true
    
    init(plan: Plan) {
        self.plan = plan
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                if plan.arrangedExercises.isEmpty {
                    PlaceholderView()
                        .veriticalSpacing(.center)
                        .offset(y: -32)
                } else {
                    ArrangedExercisesListView()
                }
            }
            .background(Color.themeStyle.theme.background)
            .veriticalSpacing(.top)
            .navigationTitle(plan.name)
            .sheet(isPresented: $isAdding, content: {
                CreateArrangedExerciseView(plan: plan, incrementalOrderNumber: plan.arrangedExercises.count, completion: { _ in

                })
                    .presentationDetents([.height(460)])
                    .presentationCornerRadius(16)
            })
            .sheet(item: $exerciseToEdit) { exercise in
                EditArrangedExerciseView(arrangedExercise: exercise, isPlanMode: true)
                    .presentationDetents([.fraction(0.7)])
                    .presentationCornerRadius(16)
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
    
    @ViewBuilder
    func ArrangedExercisesListView() -> some View {
        List {
            ForEach(plan.arrangedExercises.sorted(by: { $0.order < $1.order }), id: \.self) { exercise in
                ArrangedExerciseCard(exercise: exercise, isItemEditable: $isItemEditable)
                    .veriticalSpacing(.center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            /// Delete items
                            withAnimation {
                                deleteExericse(exercise)
                            }
                        }) {
                            Image(systemName: "trash")
                                .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        }
                        .tint(Color.themeStyle.theme.accent)
                    }
                    .onTapGesture {
                        self.exerciseToEdit = exercise
                    }
            }
            .onMove(perform: { indexSet, newOffset in
                updateOrderNumbers(from: indexSet, to: newOffset)
            })
        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .background(Color.themeStyle.theme.background)
    }
    
    
    @ViewBuilder
    func PlaceholderView() -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(LocalizationProvider.noExercises.nameKey)
                .font(.title2)
                .fontWeight(.bold)
            Text(LocalizationProvider.startAddingExerciseToPlan.nameKey)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            
            Button(action: {
                isAdding.toggle()
            }) {
                Text(LocalizationProvider.addExercise.nameKey)
                    .fontWeight(.semibold)
                    .background(Color.themeStyle.theme.accent)
                    .foregroundColor(Color.themeStyle.theme.white)
                    .horizontalSpacing(.center)
                    .frame(height: 44)
            }
            .background(Color.themeStyle.theme.accent)
            .cornerRadius(8)
            .padding(.horizontal, 88)
            .padding(.top, 16)
        }
    }
    
    func updateOrderNumbers(from indexSet: IndexSet, to offset: Int) {
        guard let itemIndex = indexSet.first else { return }
            
        var exercises = plan.arrangedExercises.sorted(by: { $0.order < $1.order })
                
        // Ensure that the provided offset is within a valid range
        if offset < 0 || offset > exercises.count {
            return
        }
        
        // Remove the moved item from the exercises array
        let movedExercise = exercises.remove(at: itemIndex)
        
        // Insert the moved item at the new position (offset)
        
        if offset > itemIndex  {
            exercises.insert(movedExercise, at: offset - 1)
        } else {
            exercises.insert(movedExercise, at: offset)
        }
        
        // Update the order numbers of all exercises in the updated array
        for (index, exercise) in exercises.enumerated() {
            exercise.order = index
        }
        
        // Assign the updated exercises array back to your currentPlan
        plan.arrangedExercises = exercises
    }
    
    func deleteExericse(_ exercise: ArrangedExercise) {
        if let index = plan.arrangedExercises.firstIndex(where: { $0 == exercise }) {
            plan.arrangedExercises.remove(at: index)
            context.delete(exercise)
        }

        // Update the order numbers of all exercises in the updated array
        for (index, exercise) in plan.arrangedExercises.enumerated() {
            exercise.order = index
        }
    }
}
