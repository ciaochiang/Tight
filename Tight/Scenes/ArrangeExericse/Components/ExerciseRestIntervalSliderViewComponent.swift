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
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizationProvider.restIntervals.nameKey)
                .font(.subheadline)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(arrangedExercise.restIntevals.formatIntervalToMinutesSeconds)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                    .frame(width: 48, alignment: .leading)
                
                Slider(value: $arrangedExercise.restIntevals, in: 30...180, step: 10.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
}
#Preview {
    ExerciseRestIntervalSliderViewComponent(arrangedExercise: Mocks.mockArrangedExercise)
}
