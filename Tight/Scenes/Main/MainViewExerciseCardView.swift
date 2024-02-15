//
//  MainViewExerciseCardView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/24.
//

import SwiftUI
import SwiftData

struct MainViewExerciseCardView: View {
    @Bindable var exercise: ArrangedExercise
    @Binding var isItemEditable: Bool
  
    var body: some View {
        /// Content
        VStack(alignment: .leading, spacing: 8) {
            ExerciseNameView(name: exercise.exercise.name, 
                             isCompleted: exercise.isCompleted,
                             isItemEditable: isItemEditable)
            ExerciseDetailsView(weight: exercise.weight, 
                                weightUnit: exercise.weightUnit,
                                repetitions: exercise.repetitions,
                                sets: exercise.sets,
                                restInterval: exercise.restIntevals,
                                isItemEditable: isItemEditable).horizontalSpacing(.leading)
            
            if !exercise.tags.isEmpty {
                ExerciseTagsView(tags: exercise.tags).horizontalSpacing(.leading).padding(.top, 8)
            }
        }
        .horizontalSpacing(.leading)
        .padding()
        .background(Color.themeStyle.theme.background)
    }
    
    @ViewBuilder
    func ExerciseDetailsView(weight: Double, 
                             weightUnit: Int,
                             repetitions: Double,
                             sets: Double,
                             restInterval: TimeInterval,
                             isItemEditable: Bool) -> some View {
        HStack(alignment: .center, spacing: 16) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 16)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
                
                let weightUnit = WeightUnit(value: weightUnit)
                Text("\(String(format: "%1.f", weight)) \(weightUnit.name)")
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
                Text("\(Int(repetitions))")
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
                Text("\(Int(sets))")
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
                Text(restInterval.formatIntervalToMinutesSeconds)
                    .font(.footnote)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .opacity(isItemEditable ? 1.0 : 0.4)
            }
        }
    }
    
    @ViewBuilder
    func ExerciseNameView(name: String, isCompleted: Bool, isItemEditable: Bool) -> some View {
        HStack {
            Rectangle()
                .fill(isCompleted ? Color.themeStyle.theme.accent : Color.themeStyle.theme.secondaryTextColor.opacity(0.7))
                .frame(width: 3, height: 18)
                .cornerRadius(2)
            Text(name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                .opacity(isItemEditable ? 1.0 : 0.4)
        }
    }
    
    @ViewBuilder
    func ExerciseTagsView(tags: [Int]) -> some View {
        HStack(spacing: 8) {
            ForEach(tags, id: \.self) { int in
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
    MainViewExerciseCardView(exercise: Mocks.mockArrangedExercise, isItemEditable: .constant(true))
}

