//
//  TraningSessionExtendedView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/3.
//

import SwiftUI

struct TrainingSessionExtendedView: View {
    @Binding var content: TrainingSessionContent
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var trainingSessionManager: TrainingSessionManager
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    if let startTime = content.startTime {
                        TimerView(startTime: startTime,
                                  restStartTime: content.restStartTime,
                                  restInterval: content.restInterval,
                                  isCountDown: content.state == .resting)
                        .font(.system(size: 100))
                        .tracking(5.0)
                        .frame(height: 80)
                    }
                    
                    CircularProgressView(content: "\(content.indexOfSet + 1)", 
                                         progress: content.setsProgress, font: .system(size: 72), 
                                         lineWidth: 10,
                                         width: 132,
                                         height: 132)
                    .frame(maxHeight: .infinity, alignment: .center)

                                        
                    if let exercise = content.currentExercise {
                        let weightUnit = WeightUnit(value: exercise.weightUnit)
                        ExerciseInfoView(exerciseName: exercise.exercise.name,
                                         weight: exercise.weight,
                                         weightUnit: weightUnit,
                                         repetition: exercise.repetitions)
                        .padding(.bottom)
                    }
                    
                    LinearProgressView(progress: content.totalProgress)
                        .cornerRadius(2.0)
                        .padding(.bottom, 32)
                        .padding(.horizontal)
                    ControlsView(state: content.state, exerciseID: content.exerciseID)
                        .padding(.bottom, 32)
                }
                .padding()
            }
            .onChange(of: content.state, { oldValue, newValue in
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
    func ControlsView(state: TTSessionState, exerciseID: String?) -> some View {
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
                    if let exerciseID = exerciseID {
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
}

#Preview {
    @State var content = Mocks.trainingContent
    return TrainingSessionExtendedView(content: $content)
        .environmentObject(TrainingSessionManager())
}
