//
//  ArrangedExerciseCard.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/24.
//

import SwiftUI
import SwiftData

struct ArrangedExerciseCard: View {
    @Bindable var exercise: ArrangedExercise
    @Binding var isItemEditable: Bool
  
    var body: some View {
        /// Content
        ExerciseView()
            .horizontalSpacing(.leading)
            .padding(.leading, 4)
            .background(Color.themeStyle.theme.background)
    }
    
    @ViewBuilder
    func ExerciseView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ExerciseNameView()
            ExerciseDetailsView().horizontalSpacing(.leading)
            
            if !exercise.tags.isEmpty {
                ExerciseTagsView().horizontalSpacing(.leading).padding(.top, 8)
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
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 16)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
                
                let weightUnit = WeightUnit(value: exercise.weightUnit)
                Text("\(String(format: "%1.f", exercise.weight)) \(weightUnit.name)")
                    .font(.footnote)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
            }
            
            HStack {
                Image(systemName: "repeat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 12)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
                Text("\(Int(exercise.repetitions))")
                    .font(.footnote)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
            }
            
            HStack {
                Image(systemName: "square.stack.3d.down.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 18)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
                Text("\(Int(exercise.sets))")
                    .font(.footnote)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
            }
            
            HStack {
                Image(systemName: "clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 14)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
                Text(exercise.restIntevals.formatIntervalToMinutesSeconds)
                    .font(.footnote)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
            }
        }
    }
    
    @ViewBuilder
    func ExerciseNameView() -> some View {
        HStack {
            Rectangle()
                .fill(exercise.isCompleted ? Color.themeStyle.theme.secondaryAccent : Color.themeStyle.theme.secondaryTextColor)
                .frame(width: 3, height: 18)
                .cornerRadius(2)
            Text(exercise.exercise.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                .opacity(isItemEditable ? 1.0 : 0.4)
        }

    }
    
    @ViewBuilder
    func ExerciseTagsView() -> some View {
        HStack(spacing: 8) {
            ForEach(exercise.tags, id: \.self) { int in
                VStack {
                    Text(ExerciseTag(rawValue: int)?.namekey ?? "")
                        .font(.footnote)
                        .background(.clear)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                }
                .background(Color.themeStyle.theme.secondaryBackground.opacity(0.3))
                .cornerRadius(4)
            }
        }
    }
}


#Preview {
    ArrangedExerciseCard(exercise: Mocks.mockArrangedExercise, isItemEditable: .constant(true))
}

