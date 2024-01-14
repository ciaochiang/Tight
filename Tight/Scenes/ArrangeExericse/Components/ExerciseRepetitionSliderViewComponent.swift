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
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizationProvider.repetitions.nameKey)
                .font(.subheadline)
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
    }
}
#Preview {
    ExerciseRepetitionSliderViewComponent(arrangedExercise: Mocks.mockArrangedExercise)
}
