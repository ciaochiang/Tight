//
//  ExerciseRepetitionSliderViewComponent.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct ExerciseRepetitionSliderViewComponent: View {
    @Bindable var arrangedExercise: ArrangedExercise
    @AppStorage(Constants.DEFAULT_EXERCISE_REPETITIONS) private var defaultRepetitions: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizationProvider.repetitions.nameKey)
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", arrangedExercise.repetitions))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                    .frame(width: 24, alignment: .leading)
                
                Slider(value: $arrangedExercise.repetitions, in: 1...20, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
        .frame(height: 44)
        .onAppear {
            arrangedExercise.repetitions = defaultRepetitions
        }
    }
}
#Preview {
    ExerciseRepetitionSliderViewComponent(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
