//
//  ExerciseWeightSliderViewComponent.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/1.
//

import SwiftUI

struct ExerciseWeightSliderViewComponent: View {
    @Bindable var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizationProvider.weight.nameKey)
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", arrangedExercise.weight))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                    .frame(width: 24, alignment: .leading)
                
                Slider(value: $arrangedExercise.weight, in: 1...6, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
        .frame(height: 44)
    }
}

#Preview {
    ExerciseWeightSliderViewComponent(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
