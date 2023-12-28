//
//  EditArrangedExerciseView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct EditArrangedExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var arrangedExercise: ArrangedExercise
    @State private var isPresented: Bool = false
    var isPlanMode: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ExerciseSelectorViewComponent(isPresented: $isPresented, arrangedExericse: arrangedExercise).horizontalSpacing(.leading)
                ExerciseRepetitionSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
                ExerciseSetsSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
                ExerciseRestIntervalSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
            }
            .padding()
            .veriticalSpacing(.bottom)
            .sheet(isPresented: $isPresented, content: {
                ExercisePickerView(title: "Pick Exercise",
                                   selectedExercise: arrangedExercise.exercise,
                                   callback: { exercise in
                    arrangedExercise.exercise = exercise
                    isPresented.toggle()
                })
                .presentationDetents([.large])
            })
            .navigationTitle(arrangedExercise.exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.themeStyle.theme.background)
            .toolbar {
                if !isPlanMode {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            arrangedExercise.isCompleted.toggle()
                            dismiss()
                        }) {
                            Label("Check", systemImage: arrangedExercise.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                        }
                        .tint(arrangedExercise.isCompleted ? Color.themeStyle.theme.green : Color.gray)
                    }
                }

                
                ToolbarItem(placement: .topBarTrailing) {
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
}


#Preview {
    EditArrangedExerciseView(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
