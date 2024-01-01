//
//  ExerciseRestIntervalSliderViewComponent.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct ExerciseRestIntervalSliderViewComponent: View {
    @Bindable var arrangedExercise: ArrangedExercise
    @AppStorage(Constants.DEFAULT_EXERCISE_REST_INTERVALS) private var defaultRestIntervals: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizationProvider.restIntervals.nameKey)
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(arrangedExercise.restIntevals.formatIntervalToMinutesSeconds)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                    .frame(width: 48, alignment: .leading)
                
                Slider(value: $arrangedExercise.restIntevals, in: 0...180, step: 10.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
        .frame(height: 44)
        .onAppear {
            arrangedExercise.restIntevals = defaultRestIntervals
        }
    }
}
#Preview {
    ExerciseRestIntervalSliderViewComponent(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
