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
                .foregroundStyle(exercise.isCompleted ? Color.themeStyle.theme.secondaryAccent : Color.themeStyle.theme.secondaryTextColor)
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
            
            if !exercise.tags.isEmpty {
                ExerciseTagsView().horizontalSpacing(.leading)
            }
        }
        .horizontalSpacing(.leading)
        .padding()
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
    
    @ViewBuilder
    func ExerciseTagsView() -> some View {
        HStack(spacing: 8) {
            ForEach(exercise.tags, id: \.self) { int in
                VStack {
                    Text(ExerciseTag(rawValue: int)?.name ?? "")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .background(.clear)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .foregroundColor(.white)
                }
                .background(Color.themeStyle.theme.accent)
                .cornerRadius(4)
            }
        }
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
                                                   tags: [1,2,4],
                                                   isCompleted: false)))
}

