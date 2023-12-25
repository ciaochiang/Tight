//
//  ExerciseSetsSliderViewComponent.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct ExerciseSetsSliderViewComponent: View {
    @Bindable var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sets")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", arrangedExercise.sets))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $arrangedExercise.sets, in: 1...6, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
}

#Preview {
    ExerciseSetsSliderViewComponent(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
