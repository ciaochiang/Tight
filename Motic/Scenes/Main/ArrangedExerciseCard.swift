//
//  ArrangedExerciseCard.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/24.
//

import SwiftUI
import SwiftData

struct ArrangedExerciseCard: View {
    @Binding var exercise: ArrangedExercise
  
    var body: some View {
        /// Content
        HStack(spacing: 8) {
            Rectangle()
                .foregroundStyle(exercise.isCompleted ? Color.themeStyle.theme.green : Color.themeStyle.theme.secondaryTextColor)
                .frame(width: 2)
            
            ExerciseView()
                .frame(maxHeight: .infinity)
        }
        .horizontalSpacing(.leading)
        .background(Color.themeStyle.theme.background)
    }
    
    @ViewBuilder
    func ExerciseView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ExerciseNameView()
            ExerciseDetailsView().horizontalSpacing(.leading)
        }
        .horizontalSpacing(.leading)
        .padding()
//        .background(Color.themeStyle.theme.background, in: .rect(topLeadingRadius: 16, bottomLeadingRadius: 16))
    }
    
    @ViewBuilder
    func ExerciseDetailsView() -> some View {
        HStack(alignment: .center, spacing: 16) {
            Label("\(Int(exercise.repetitions))", systemImage: "repeat")
                .font(.caption)
                .foregroundColor(Color.themeStyle.theme.primaryTextColor)
            
            Label("\(Int(exercise.sets))", systemImage: "square.stack.3d.down.right")
                .font(.caption)
                .foregroundColor(Color.themeStyle.theme.primaryTextColor)
            
            Label(exercise.restIntevals.formatIntervalToMinutesSeconds, systemImage: "clock")
                .font(.caption)
                .foregroundColor(Color.themeStyle.theme.primaryTextColor)
        }
    }
    
    @ViewBuilder
    func ExerciseNameView() -> some View {
        Text(exercise.exercise.name)
            .fontWeight(.semibold)
            .foregroundStyle(exercise.isCompleted ? Color.themeStyle.theme.secondaryTextColor : Color.themeStyle.theme.primaryTextColor)
            .strikethrough(exercise.isCompleted, color: Color.themeStyle.theme.secondaryTextColor)
    }
}


#Preview {
    ArrangedExerciseCard(exercise: .constant(.init(exercise: .none,
                                                   repetitions: 0,
                                                   sets: 0,
                                                   weight: 0,
                                                   durationOfSet: 0,
                                                   restIntevals: 0,
                                                   order: 0,
                                                   tags: [],
                                                   isCompleted: false)))
}

