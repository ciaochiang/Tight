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
                Text("\(trainingSessionManager.exerciseSetIndex + 1)")
                    .foregroundStyle(Color.themeStyle.theme.white.opacity(0.8))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .overlay {
                        ZStack {
                            Circle()
                                .stroke( // 1
                                    Color.white.opacity(0.7),
                                    lineWidth: 2
                                )
                                .frame(width: 48, height: 48)
                            
                            Circle()
                                .trim(from: 0, to: trainingSessionManager.exerciseSetCompletionProgress)
                                .stroke( // 1
                                    Color.themeStyle.theme.accent,
                                    lineWidth: 4
                                )
                                .frame(width: 48, height: 48)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: trainingSessionManager.exerciseSetCompletionProgress)
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

                    ExerciseInfoView(state: trainingSessionManager.state,
                                     exerciseName: trainingSessionManager.currentExercise?.exercise.name ?? "",
                                     weight: trainingSessionManager.currentExercise?.weight ?? 0,
                                     repetition: trainingSessionManager.currentExercise?.repetitions ?? 0)
                }
                .padding(.leading, 8)
                
                ControlsView(isResting: trainingSessionManager.restStartTime != nil)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, trainingSessionManager.exerciseCount > 1 ? 0 : 12)
            
            /// Only display stage progress view arranged exercises more than `1`
            if trainingSessionManager.exerciseCount > 1 {
                StagesView(progress: trainingSessionManager.sessionProgress)
            }
        }
        .background(Color.themeStyle.theme.black.opacity(0.8))
    }
    
    @ViewBuilder
    func StagesView(progress: Double) -> some View {
        ProgressView(value: progress)
            .progressViewStyle(.linear)
            .background(Color.white.opacity(0.7))
            .animation(.easeInOut, value: progress)
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
    func ExerciseInfoView(state: TrainingSessionState, exerciseName: String, weight: Double, repetition: Double) -> some View {
        VStack {
            Text(state == .resting ? LocalizationProvider.breakTimeTitle.localizedString : exerciseName)
                .font(.headline)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .minimumScaleFactor(0.8)
                .foregroundColor(state == .resting ? Color.themeStyle.theme.primaryTextColor : Color.themeStyle.theme.accent.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.opacity)
            
            Text(state == .resting ? LocalizationProvider.breakTimeSubtitle.localizedString : "\(Int(weight))kg x \(Int(repetition))")
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .font(.subheadline)
                .minimumScaleFactor(0.8)
                .fontWeight(.semibold)
                .foregroundColor(Color.white.opacity(0.8))
                .contentTransition(.opacity)
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
