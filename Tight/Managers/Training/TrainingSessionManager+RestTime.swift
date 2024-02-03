//
//  TrainingSessionManager+RestTime.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/1.
//

import Foundation

// MARK: Rest Time Handler
extension TrainingSessionManager {
    func onRestTimeStart(currentTime: Date, restTimeInterval: TimeInterval) -> RestTimeFrame {
        /// Schedule a rest time notification
        scheduleNotification(timeInterval: restTimeInterval)
        
        return RestTimeFrame(startTime: currentTime)
    }
    
    func onRestTimeEnd(currentTime: Date, plan: Plan, restTimeFrame: RestTimeFrame) {
        /// Set `endTime` to current rest time frame and save to `trainingLog`
        let operation = BlockOperation {
            restTimeFrame.endTime = currentTime
            plan.trainingLog?.restTimeFrames.append(restTimeFrame)
        }
        operationQueue.addOperation(operation)
        
        /// Cancel all scheduled notification
        cancelScheduledNotifications()
    }
}
