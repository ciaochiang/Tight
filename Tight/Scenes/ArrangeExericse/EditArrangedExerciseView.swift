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
                ExerciseTagPickerViewComponent(arrangedExercise: arrangedExercise)
                    .horizontalSpacing(.leading)
            }
            .padding()
            .veriticalSpacing(.bottom)
            .sheet(isPresented: $isPresented, content: {
                ExercisePickerView(title: LocalizationProvider.pickExercise.nameKey,
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
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            arrangedExercise.isCompleted.toggle()
                            dismiss()
                        }) {
                            Image(systemName: arrangedExercise.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                                .symbolVariant(.fill)
                        }
                        .tint(arrangedExercise.isCompleted ? Color.themeStyle.theme.secondaryAccent : Color.gray)
                    }
                }

                
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


#Preview {
    let previewContainer = PreviewContainer([ArrangedExercise.self])
    return EditArrangedExerciseView(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false)).modelContainer(previewContainer.container)
}
