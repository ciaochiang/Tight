//
//  PlanEditView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI
import SwiftData

struct EditPlanPresetView: View {
    @Bindable var plan: Plan
    @State private var isAdding: Bool = false
    @State private var exercises: [ArrangedExercise]
    @State private var exerciseToEdit: ArrangedExercise?
    
    init(plan: Plan) {
        self.plan = plan
        _exercises = .init(wrappedValue: plan.arrangedExercises.sorted { $0.order < $1.order })
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                if exercises.isEmpty {
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
                    exercises = plan.arrangedExercises.sorted { $0.order < $1.order }
                })
                    .presentationDetents([.height(400)])
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
            ForEach($exercises, id: \.self) { $exercise in
                ArrangedExerciseCard(exercise: $exercise)
                    .veriticalSpacing(.center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            /// Delete items
                            withAnimation {
                                if let index = exercises.firstIndex(where: { $0 == exercise }) {
                                    exercises.remove(at: index)
                                }
                                
                                if let index = plan.arrangedExercises.firstIndex(where: { $0 == exercise }) {
                                    plan.arrangedExercises.remove(at: index)
                                }
                                
                                updateOrderNumbers()
                                exercises = plan.arrangedExercises.sorted { $0.order < $1.order }
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                                .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        }
                        .tint(Color.themeStyle.theme.accent)
                    }
                    .onTapGesture {
                        self.exerciseToEdit = exercise
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
    
    
    @ViewBuilder
    func PlaceholderView() -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text("No Exercises")
                .font(.title2)
                .fontWeight(.bold)
            Text("Start adding exercises to your plan.")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            
            Button(action: {
                isAdding.toggle()
            }) {
                Text(LocalizationProvider.addExercise.nameKey)
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
    }
    
    func updateOrderNumbers() {
        for i in 0..<exercises.count {
            let exercise = exercises[i]
            exercise.order = i
        }
        
        plan.arrangedExercises = exercises
    }
}
