//
//  WatchSessionDelegate.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/21.
//

import WatchConnectivity

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        
        do {
            guard let exercise = TrainingSessionManager.shared.currentExercise else { return }
            try session.updateApplicationContext(["state": TrainingSessionManager.shared.state.rawValue,
                                                  "currentExerciseID": exercise.id.uuidString,
                                                  "exerciseName": exercise.exercise.name,
                                                  "startTime": exercise.startTime ?? .now,
                                                  "weight": exercise.weight,
                                                  "weightUnit": exercise.weightUnit,
                                                  "repetitions": exercise.repetitions,
                                                  "indexOfSet": TrainingSessionManager.shared.exerciseSetIndex,
                                                  "currentSetsProgress": TrainingSessionManager.shared.exerciseSetCompletionProgress
                                                 ])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    /// When watch is light out,  the reachability will be changed to `false`, when watch is light up, the reachaiiliby will be change to `true`
    /// use this timing to get current training session states from phone app.
    func sessionReachabilityDidChange(_ session: WCSession) {
        let trainingSessionManager = TrainingSessionManager.shared
        guard session.isReachable,
              let exercise = trainingSessionManager.currentExercise,
                let startTime = trainingSessionManager.startTime else { return }
        
        session.sendMessage(["state": TrainingSessionManager.shared.state.rawValue,
                             "currentExerciseID": exercise.id.uuidString,
                             "exerciseName": exercise.exercise.name,
                             "startTime": startTime,
                             "weight": exercise.weight,
                             "weightUnit": exercise.weightUnit,
                             "repetitions": exercise.repetitions,
                             "restStartTime": TrainingSessionManager.shared.restStartTime ?? .now,
                             "restIntervals": TrainingSessionManager.shared.restIntervals ?? 0,
                             "indexOfSet": TrainingSessionManager.shared.exerciseSetIndex,
                             "currentSetsProgress": TrainingSessionManager.shared.exerciseSetCompletionProgress
                            ], replyHandler: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let action = message["action"] as? String else { return }
        
        switch action {
        case "complete":
            if let exerciseID = TrainingSessionManager.shared.currentExercise?.id {
                TrainingSessionManager.shared.completeCurrentSet(exerciseID: exerciseID.uuidString)
            }
        case "skip":
            TrainingSessionManager.shared.endRest()
        case "end":
            TrainingSessionManager.shared.stopTrainingSession()
        default: break
        }
    }
}
