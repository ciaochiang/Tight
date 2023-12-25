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
    
    /// View Properties
    @State private var isPresented: Bool = false
    
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
        }
    }
}


#Preview {
    EditArrangedExerciseView(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
