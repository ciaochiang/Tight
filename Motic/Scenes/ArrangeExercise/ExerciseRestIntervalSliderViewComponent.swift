//
//  ExerciseRestIntervalSliderViewComponent.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct ExerciseRestIntervalSliderViewComponent: View {
    @Bindable var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rest Intervals")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(arrangedExercise.restIntevals.formatIntervalToMinutesSeconds)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $arrangedExercise.restIntevals, in: 0...180, step: 10.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
}
#Preview {
    ExerciseRestIntervalSliderViewComponent(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
