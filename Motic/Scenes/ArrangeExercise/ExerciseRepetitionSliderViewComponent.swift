//
//  ExerciseRepetitionSliderViewComponent.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct ExerciseRepetitionSliderViewComponent: View {
    @Bindable var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repetitions")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", arrangedExercise.repetitions))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $arrangedExercise.repetitions, in: 1...20, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
}
#Preview {
    ExerciseRepetitionSliderViewComponent(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
