//
//  TraningSessionExtendedView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/3.
//

import SwiftUI

struct TrainingSessionExtendedView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var trainingSessionManager: TrainingSessionManager
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    if let startTime = trainingSessionManager.content.startTime {
                        ElapsedTimeView(state: trainingSessionManager.content.state, 
                                        startTime: startTime,
                                        restStartTime: trainingSessionManager.content.restStartTime,
                                        restIntervals: trainingSessionManager.content.restInterval)
                        .frame(height: 80)
                    }
                    
                    SetsProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                    
                    if let exercise = trainingSessionManager.content.currentExercise {
                        let weightUnit = WeightUnit(value: exercise.weightUnit)
                        ExerciseInfoView(exerciseName: exercise.exercise.name,
                                         weight: exercise.weight,
                                         weightUnit: weightUnit,
                                         repetition: exercise.repetitions)
                        .padding(.bottom)
                    }
                    
                    TotalProgressView(progress: trainingSessionManager.content.totalProgress)
                        .padding(.bottom, 32)
                        .padding(.horizontal)
                    ControlsView(state: trainingSessionManager.content.state)
                        .padding(.bottom, 32)
                }
                .padding()
            }
            .onChange(of: trainingSessionManager.content.state, { oldValue, newValue in
                if newValue == .notStarted {
                    DispatchQueue.main.async {
                        self.dismiss()
                    }
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Label(LocalizationProvider.close.nameKey, systemImage: "chevron.down")
                    }
                    .tint(Color.themeStyle.theme.primary)
                }
            }
            .background(Color.themeStyle.theme.background)
        }
    }
    
    @ViewBuilder
    func ExerciseInfoView(exerciseName: String, weight: Double, weightUnit: WeightUnit, repetition: Double) -> some View {
        VStack(spacing: 8) {
            Text(exerciseName)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
            Text("\(Int(weight))\(weightUnit.name) x \(Int(repetition))")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
        }
    }
    
    @ViewBuilder
    func ElapsedTimeView(state: TTSessionState, startTime: Date, restStartTime: Date?, restIntervals: TimeInterval) -> some View {
        VStack {
            if state == .resting, let restStartTime = restStartTime {
                let restEndTime = restStartTime.addingTimeInterval(restIntervals)
                Text(timerInterval: restStartTime...restEndTime, countsDown: true)
                    .font(.system(size: 100))
                    .fontWeight(.bold)
                    .tracking(4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.themeStyle.theme.secondaryAccent)
                    .contentTransition(.numericText(countsDown: false))
            }
            else {
                Text(startTime, style: .timer)
                    .font(.system(size: 100))
                    .fontWeight(.bold)
                    .tracking(4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.themeStyle.theme.accent)
                    .contentTransition(.numericText(countsDown: false))
            }
        }
    }
    
    @ViewBuilder
    func TotalProgressView(progress: Double) -> some View {
        ProgressView(value: progress)
            .progressViewStyle(.linear)
            .background(Color.white.opacity(0.7))
            .animation(.easeInOut, value: progress)
    }
    
    @ViewBuilder
    func ControlsView(state: TTSessionState) -> some View {
        HStack {
            Button(action: {
                trainingSessionManager.endSession()
                dismiss()
            }) {
                Image(systemName: "stop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            }
            .contentShape(Rectangle())
            .tint(Color.themeStyle.theme.primaryTextColor.opacity(0.7))
            
            Spacer()
            
            
            if state == .resting {
                Button(action: {
                    trainingSessionManager.endRest()
                }) {
                    Image(systemName: "chevron.forward.2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                }
                .contentShape(Rectangle())
                .tint(Color.themeStyle.theme.primaryTextColor.opacity(0.7))
            }
            else {
                /// Done Button
                Button(action: {
                    if let exerciseID = trainingSessionManager.content.exerciseID {
                        trainingSessionManager.completeCurrentSet(exerciseID: exerciseID)
                    }
                }) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                }
                .contentShape(Rectangle())
                .tint(Color.themeStyle.theme.primaryTextColor.opacity(0.7))
            }
        }
        .padding(.horizontal, 64)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    func SetsProgressView() -> some View {
        VStack {
            Text("\(trainingSessionManager.content.indexOfSet + 1)")
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                .font(.system(size: 72))
                .fontWeight(.semibold)
                .overlay {
                    ZStack {
                        Circle()
                            .stroke( // 1
                                Color.themeStyle.theme.primary.opacity(0.3),
                                lineWidth: 10
                            )
                            .frame(width: 132, height: 132)
                        
                        Circle()
                            .trim(from: 0, to: trainingSessionManager.content.setsProgress)
                            .stroke( // 1
                                Color.themeStyle.theme.accent,
                                lineWidth: 10
                            )
                            .frame(width: 132, height: 132)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut, value: trainingSessionManager.content.setsProgress)
                    }
                }
        }
    }
}

#Preview {
    TrainingSessionExtendedView()
        .environmentObject(TrainingSessionManager())
}
