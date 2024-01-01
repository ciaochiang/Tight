//
//  ExerciseSelectorViewComponent.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct ExerciseSelectorViewComponent: View {
    @Binding var isPresented: Bool
    @Bindable var arrangedExericse: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationProvider.exercise.nameKey)
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            Button(action: {
                /// Display Exercise Picker View
                isPresented.toggle()
            }) {
                Text(arrangedExericse.exercise.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .horizontalSpacing(.leading)
        }
    }
}

#Preview {
    ExerciseSelectorViewComponent(isPresented: .constant(false), arrangedExericse: Mocks.mockArrangedExercise)
}
