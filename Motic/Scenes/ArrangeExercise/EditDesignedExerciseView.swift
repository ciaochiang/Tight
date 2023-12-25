//
//  EditDesignedExerciseView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

//struct EditDesignedExerciseView: View {
//    @Environment(\.dismiss) private var dismiss
//    @Bindable var designedExercise: DesignedExercise
//    @State private var isExercisePickerViewPresented: Bool = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack(alignment: .leading, spacing: 16) {
//                ExerciseView().horizontalSpacing(.leading)
//                RepetitionView().horizontalSpacing(.leading)
//                SetsView().horizontalSpacing(.leading)
//                RestIntervalsView().horizontalSpacing(.leading)
//            }
//            .padding()
//            .veriticalSpacing(.bottom)
//            .sheet(isPresented: $isExercisePickerViewPresented, content: {
//                ExercisePickerView(title: "Pick Exercise", selectedExercise: designedExercise.exercise, callback: { exercise in
//                    designedExercise.exercise = exercise
//                    isExercisePickerViewPresented.toggle()
//                })
//                    .presentationDetents([.large])
//            })
//        }
//    }
//
//    @ViewBuilder
//    func ExerciseView() -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Exercise")
//                .font(.caption)
//                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
//            
//            Button(action: {
//                /// Display Exercise Picker View
//                isExercisePickerViewPresented.toggle()
//            }) {
//                Text(designedExercise.exercise.name)
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    func RepetitionView() -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Repetitions")
//                .font(.caption)
//                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
//            
//            HStack(alignment: .center, spacing: 8) {
//                Text(String(format: "%.0f", designedExercise.repetitions))
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
//                
//                Slider(value: $designedExercise.repetitions, in: 1...20, step: 1.0)
//                    .accentColor(Color.themeStyle.theme.accent)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    func SetsView() -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Sets")
//                .font(.caption)
//                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
//            
//            HStack(alignment: .center, spacing: 8) {
//                Text(String(format: "%.0f", designedExercise.sets))
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
//                
//                Slider(value: $designedExercise.sets, in: 1...6, step: 1.0)
//                    .accentColor(Color.themeStyle.theme.accent)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    func RestIntervalsView() -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Rest Intervals")
//                .font(.caption)
//                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
//            
//            HStack(alignment: .center, spacing: 8) {
//                Text(designedExercise.restIntevals.formatIntervalToMinutesSeconds)
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
//                
//                Slider(value: $designedExercise.restIntevals, in: 0...180, step: 10.0)
//                    .accentColor(Color.themeStyle.theme.accent)
//            }
//        }
//    }
//}
//
//
//#Preview {
//    EditDesignedExerciseView(designedExercise: .init(exercise: .arnoldPress, repetitions: 0, sets: 0, restIntevals: 0, order: 0))
//}
