//
//  TrainingSessionManager+TraningLog.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/1.
//

import Foundation

// MARK: Training Log
extension TrainingSessionManager {
    func createTrainingLog() {
        /// - Create a training log if it's not existed or update existing one
        /// - Set  `currentTime` to  current exercise's `startTime`
        let currentTime = Date.now
        let trainingLog = TrainingLog(startTime: currentTime)
        trainingLog.startTime = currentTime
        plan?.trainingLog = trainingLog
    }
}
