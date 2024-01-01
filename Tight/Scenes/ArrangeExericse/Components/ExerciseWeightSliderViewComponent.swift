//
//  ExerciseWeightSliderViewComponent.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/1.
//

import SwiftUI

struct ExerciseWeightSliderViewComponent: View {
    @Bindable var arrangedExercise: ArrangedExercise
    @State private var weightValue: Double?
    @AppStorage(Constants.DEFAULT_EXERCISE_WEIGHT_UNIT) private var defaultWeightUnit: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationProvider.weight.nameKey)
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                TextField("0", value: $arrangedExercise.weight, format: .number)
                    .font(.subheadline)
                    .keyboardType(.numberPad)
                
                Text(WeightUnit(rawValue: defaultWeightUnit)?.nameKey ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    ExerciseWeightSliderViewComponent(arrangedExercise: Mocks.mockArrangedExercise)
}
