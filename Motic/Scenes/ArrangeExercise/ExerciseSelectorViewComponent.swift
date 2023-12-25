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
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise")
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
            }
        }
    }
}

#Preview {
    ExerciseSelectorViewComponent(isPresented: .constant(false), arrangedExericse: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false))
}
