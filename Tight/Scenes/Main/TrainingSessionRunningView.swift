//
//  TrainingSessionRunningView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/10.
//

import SwiftUI

struct TrainingSessionRunningView: View {
    @EnvironmentObject private var trainingSessionManager: TrainingSessionManager
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                /// Sets Progress
                Text("\(trainingSessionManager.currentIndexOfSet)")
                    .foregroundStyle(Color.themeStyle.theme.white.opacity(0.8))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .overlay {
                        ZStack {
                            Circle()
                                .stroke( // 1
                                    Color.white.opacity(0.7),
                                    lineWidth: 4
                                )
                                .frame(width: 48, height: 48)
                            
                            Circle()
                                .trim(from: 0, to: trainingSessionManager.currentSetsProgress)
                                .stroke( // 1
                                    Color.themeStyle.theme.accent,
                                    lineWidth: 4
                                )
                                .frame(width: 48, height: 48)
                                .rotationEffect(.degrees(-90))
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                
                VStack(spacing: 4) {
                    if let startTime = trainingSessionManager.startTime {
                        ElapsedTimeView(startTime: startTime,
                                        restStartTime: trainingSessionManager.restStartTime,
                                        restIntervals: trainingSessionManager.restIntervals)
                    }

                    ExerciseInfoView(isResting: trainingSessionManager.restStartTime != nil,
                                     exerciseName: trainingSessionManager.currentExercise?.exercise.name ?? "",
                                     weight: trainingSessionManager.currentExercise?.weight ?? 0,
                                     repetition: trainingSessionManager.currentExercise?.repetitions ?? 0)
                }
                .padding(.leading, 8)
                
                ControlsView(isResting: trainingSessionManager.restStartTime != nil)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            StagesView(totalExerciseCount: trainingSessionManager.totalExerciseCount,
                       currentStage: trainingSessionManager.currentStage)
        }
    }
    
    @ViewBuilder
    func SetsProgressView(indexOfSet: Int, totalSetsCount: Int) -> some View {
        ProgressView(value: CGFloat(indexOfSet) / CGFloat(totalSetsCount)) {
            Text("\(indexOfSet)")
        }
        .progressViewStyle(CircularProgressViewStyle(tint: Color.themeStyle.theme.accent))
    }
    
    @ViewBuilder
    func StagesView(totalExerciseCount: Int, currentStage: Int) -> some View {
        ProgressView(value: CGFloat(currentStage), total: CGFloat(totalExerciseCount))
            .progressViewStyle(.linear)
            .background(Color.white.opacity(0.7))
    }
    
    @ViewBuilder
    func ControlsView(isResting: Bool) -> some View {
        HStack(spacing: 16) {
            /// Stop Button
            Button(action: {
                trainingSessionManager.stopTrainingSession()
            }) {
                Image(systemName: "stop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }
            .frame(width: 44, height: 44)
            .background(Color.white)
            .tint(Color.black.opacity(0.7))
            .cornerRadius(22)
            
            if isResting {
                Button(action: {
                    trainingSessionManager.endRest()
                }) {
                    Image(systemName: "chevron.forward.2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
                .tint(Color.black.opacity(0.7))
                .frame(width: 44, height: 44)
                .background(Color.white)
                .cornerRadius(22)
            }
            else {
                /// Done Button
                Button(action: {
                    if let exerciseID = trainingSessionManager.currentExercise?.id {
                        trainingSessionManager.completeCurrentSet(exerciseID: exerciseID.uuidString)
                    }
                }) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
                .frame(width: 44, height: 44)
                .background(Color.white)
                .tint(Color.black.opacity(0.7))
                .cornerRadius(22)
            }
        }
    }
    
    @ViewBuilder
    func ExerciseInfoView(isResting: Bool, exerciseName: String, weight: Double, repetition: Double) -> some View {
        VStack {
            if isResting {
                Text(LocalizationProvider.breakTimeTitle.nameKey)
                    .font(.headline)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(LocalizationProvider.breakTimeSubtitle.nameKey)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.subheadline)
                    .minimumScaleFactor(0.8)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            }
            else {
                Text(exerciseName)
                    .font(.headline)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color.themeStyle.theme.accent.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(Int(weight))kg x \(Int(repetition))")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.subheadline)
                    .minimumScaleFactor(0.8)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white.opacity(0.8))
            }
        }
    }
    
    @ViewBuilder
    func ElapsedTimeView(startTime: Date, restStartTime: Date?, restIntervals: TimeInterval?) -> some View {
        if let restStartTime = restStartTime, let restIntervals = restIntervals {
            Text(timerInterval: restStartTime...restStartTime.addingTimeInterval(restIntervals), countsDown: true)
                .font(.title2)
                .fontWeight(.bold)
                .tracking(1.4)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.blue)
                .contentTransition(.numericText(countsDown: true))
        }
        else {
            Text(startTime, style: .timer)
                .font(.title2)
                .fontWeight(.bold)
                .tracking(1.4)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.white.opacity(0.8))
                .contentTransition(.numericText())
        }
    }
}

#Preview {
    TrainingSessionRunningView()
        .environmentObject(TrainingSessionManager())
}
