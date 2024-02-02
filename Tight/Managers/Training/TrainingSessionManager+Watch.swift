//
//  TrainingSessionManager+Watch.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/30.
//

import Foundation

extension TrainingSessionManager {
    func onUpdateWatch() {
        guard let exercise = content.currentExercise, let startTime = content.startTime else { return }
                
        /// Send message to Watch
        TTWCSession.shared.sendMessage([.state: content.state.rawValue,
                                        .exerciseID: exercise.id.uuidString,
                                        .exerciseName: exercise.exercise.name,
                                        .startTime: startTime,
                                        .weight: exercise.weight,
                                        .weightUnit: exercise.weightUnit,
                                        .repetitions: exercise.repetitions,
                                        .restStartTime: content.restStartTime ?? .now,
                                        .restInterval: content.restInterval,
                                        .indexOfSet: content.indexOfSet,
                                        .setsProgress: content.setsProgress,
                                        .totalProgress: content.totalProgress
                                       ])
    }
}
