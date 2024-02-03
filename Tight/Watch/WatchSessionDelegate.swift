//
//  WatchSessionDelegate.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/21.
//

import WatchConnectivity

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated, let exercise = trainingSessionManager.content.currentExercise else { return }
        
        TTWCSession.shared.updateApplicationContext([.state: trainingSessionManager.content.state.rawValue,
                                                     .exerciseID: exercise.id.uuidString,
                                                     .exerciseName: exercise.exercise.name,
                                                     .weight: exercise.weight,
                                                     .weightUnit: exercise.weightUnit,
                                                     .repetitions: exercise.repetitions,
                                                     .restStartTime: trainingSessionManager.content.restStartTime ?? .now,
                                                     .restInterval: trainingSessionManager.content.restInterval,
                                                     .indexOfSet: trainingSessionManager.content.indexOfSet,
                                                     .setsProgress: trainingSessionManager.content.setsProgress,
                                                     .totalProgress: trainingSessionManager.content.totalProgress
        ])
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    /// When watch is light out,  the reachability will be changed to `false`, when watch is light up, the reachaiiliby will be change to `true`
    /// use this timing to get current training session states from phone app.
    func sessionReachabilityDidChange(_ session: WCSession) {
        guard session.isReachable,
              let exercise = trainingSessionManager.content.currentExercise,
              let startTime = trainingSessionManager.content.startTime else { return }
        
        /// Send message to Watch
        TTWCSession.shared.sendMessage([.state: trainingSessionManager.content.state.rawValue,
                                        .exerciseID: exercise.id.uuidString,
                                        .exerciseName: exercise.exercise.name,
                                        .startTime: startTime,
                                        .weight: exercise.weight,
                                        .weightUnit: exercise.weightUnit,
                                        .repetitions: exercise.repetitions,
                                        .restStartTime: trainingSessionManager.content.restStartTime ?? .now,
                                        .restInterval: trainingSessionManager.content.restInterval,
                                        .indexOfSet: trainingSessionManager.content.indexOfSet,
                                        .setsProgress: trainingSessionManager.content.setsProgress,
                                        .totalProgress: trainingSessionManager.content.totalProgress
                                       ])
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let action = message["action"] as? String else { return }
        
        switch action {
        case "complete":
            if let exerciseID = message[TrainingSessionAttributes.exerciseID.name] as? String {
                DispatchQueue.main.async {
                    self.trainingSessionManager.completeCurrentSet(exerciseID: exerciseID)
                }
            }
        case "skip":
            DispatchQueue.main.async {
                self.trainingSessionManager.endRest()
            }
        case "end":
            DispatchQueue.main.async {
                self.trainingSessionManager.endSession()
            }
        default: break
        }
    }
}
