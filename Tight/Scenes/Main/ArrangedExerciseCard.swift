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
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                Text("\(String(format: "%1.f", exercise.weight)) \(WeightUnit(rawValue: exercise.weightUnit)?.name ?? "")")
                    .font(.caption)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
            }
            
            HStack {
                Image(systemName: "repeat")
                Text("\(Int(exercise.repetitions))")
                    .font(.caption)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
            }
            
            HStack {
                Image(systemName: "square.stack.3d.down.right")
                Text("\(Int(exercise.sets))")
                    .font(.caption)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
            }
            
            HStack {
                Image(systemName: "clock")
                Text(exercise.restIntevals.formatIntervalToMinutesSeconds)
                    .font(.caption)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
            }
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
                    Text(ExerciseTag(rawValue: int)?.namekey ?? "")
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
    ArrangedExerciseCard(exercise: .constant(Mocks.mockArrangedExercise))
}

