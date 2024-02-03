//
//  TrainingSessionRunningView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/10.
//

import SwiftUI

struct TrainingSessionCollapsedView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var trainingSessionManager: TrainingSessionManager
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                /// Sets Progress
                Text("\(trainingSessionManager.content.indexOfSet + 1)")
                    .foregroundStyle(Color.themeStyle.theme.primary.opacity(0.8))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .overlay {
                        ZStack {
                            Circle()
                                .stroke( // 1
                                    Color.themeStyle.theme.primary.opacity(0.3),
                                    lineWidth: 2
                                )
                                .frame(width: 44, height: 44)
                            
                            Circle()
                                .trim(from: 0, to: trainingSessionManager.content.setsProgress)
                                .stroke( // 1
                                    Color.themeStyle.theme.accent,
                                    lineWidth: 4
                                )
                                .frame(width: 44, height: 44)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: trainingSessionManager.content.setsProgress)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                
                VStack(spacing: 4) {
                    if let startTime = trainingSessionManager.content.startTime {
                        ElapsedTimeView(startTime: startTime,
                                        restStartTime: trainingSessionManager.content.restStartTime,
                                        restIntervals: trainingSessionManager.content.restInterval)
                    }

                    if let exercise = trainingSessionManager.content.currentExercise {
                        let weightUnit = WeightUnit(value: exercise.weightUnit)
                        ExerciseInfoView(state: trainingSessionManager.content.state,
                                         exerciseName: exercise.exercise.name,
                                         weight: exercise.weight,
                                         weightUnit: weightUnit,
                                         repetition: exercise.repetitions)
                    }
                }
                .padding(.leading, 8)
                
                ControlsView(isResting: trainingSessionManager.content.restStartTime != nil)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, trainingSessionManager.content.exerciseCount > 1 ? 0 : 12)
            
            /// Only display stage progress view arranged exercises more than `1`
            if trainingSessionManager.content.exerciseCount > 1 {
                StagesView(progress: trainingSessionManager.content.totalProgress)
            }
        }
        .background(Color.themeStyle.theme.background)
        .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
            case .active:
                /// App is in the background
                print("enter foreground")
                break
            case .inactive:
                /// App is transitioning between active and background states
                print("app is transitioning")
                break
            case .background:
                /// App is in the background
                print("enter background")

                break
            @unknown default: break
            }
        }
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
                trainingSessionManager.endSession()
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
                    if let exerciseID = trainingSessionManager.content.currentExercise?.id {
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
        .shadow(radius: 0)
    }
    
    @ViewBuilder
    func ExerciseInfoView(state: TTSessionState, exerciseName: String, weight: Double, weightUnit: WeightUnit, repetition: Double) -> some View {
        VStack {
            Text(state == .resting ? LocalizationProvider.breakTimeTitle.localizedString : exerciseName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.8)
                .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.opacity)
            
            Text(state == .resting ? LocalizationProvider.breakTimeSubtitle.localizedString : "\(Int(weight))\(weightUnit.name) x \(Int(repetition))")
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .font(.footnote)
                .minimumScaleFactor(0.8)
                .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                .contentTransition(.opacity)
        }
    }
    
    @ViewBuilder
    func ElapsedTimeView(startTime: Date, restStartTime: Date?, restIntervals: TimeInterval?) -> some View {
        if let restStartTime = restStartTime, let restIntervals = restIntervals {
            Text(timerInterval: restStartTime...restStartTime.addingTimeInterval(restIntervals), countsDown: true)
                .font(.title2)
                .fontWeight(.bold)
                .tracking(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.secondaryAccent)
                .contentTransition(.numericText(countsDown: true))
        }
        else {
            Text(startTime, style: .timer)
                .font(.title2)
                .fontWeight(.bold)
                .tracking(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.accent)
                .contentTransition(.numericText())
        }
    }
}

#Preview {
    TrainingSessionCollapsedView()
        .environmentObject(TrainingSessionManager())
}
