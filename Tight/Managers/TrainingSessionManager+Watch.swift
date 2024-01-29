//
//  TrainingSessionManager+Watch.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/30.
//

import Foundation

extension TrainingSessionManager {
    func onUpdateWatch() {
        guard let exercise = currentExercise, let startTime = startTime else { return }
                
        /// Send message to Watch
        TTWCSession.shared.sendMessage([.state: state.rawValue,
                                        .currentExerciseID: exercise.id.uuidString,
                                        .exerciseName: exercise.exercise.name,
                                        .startTime: startTime,
                                        .weight: exercise.weight,
                                        .weightUnit: exercise.weightUnit,
                                        .repetitions: exercise.repetitions,
                                        .restStartTime: restStartTime ?? .now,
                                        .restInterval: restInterval,
                                        .indexOfSet: indexOfSet,
                                        .setsProgress: setsProgress,
                                        .totalProgress: totalProgress
                                       ])
    }
}
