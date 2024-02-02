//
//  ContentViewModel.swift
//  TightWatch Watch App
//
//  Created by Ciao Chiang on 2024/1/21.
//

import Foundation
import SwiftUI
import WatchConnectivity
import WatchKit
import HealthKit

/**
 - NOTE: user WKExtendedRuntimeSession to monitor rest time
 - SeeAlso: https://developer.apple.com/documentation/watchkit/using_extended_runtime_sessions
 */

class ContentViewModel: NSObject, ObservableObject {
    @Published var state: TTSessionState = .notStarted
    @Published var exerciseName: String?
    @Published var exerciseID: String?
    @Published var startTime: Date?
    @Published var weight: Double = 0
    @Published var weightUnit: WeightUnit = .kilogram
    @Published var repetitions: Double = 0
    
    /// Rest Time
    @Published var restStartTime: Date?
    @Published var restInterval: TimeInterval = 0
    
    /// Progress
    @Published var indexOfSet: Int = 0
    @Published var setsProgress: Double = 0
    @Published var totalProgress: Double = 0
    
    @Published var isInteractaable: Bool = true
    
    /// Health Kit
    let healthStore = HKHealthStore()
    private lazy var logger = CustomLogger()
    private var workoutSession: HKWorkoutSession?

    /// Extended Run Time
    private var session: WKExtendedRuntimeSession?
    private var timer: Timer?
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func onClickComplete() {
        isInteractaable = false
        
        /// Send message along with `ExerciseID` because of phone app may be idle and cannot get current exercise id from `TraniningSessionManager`
        if let exerciseID = exerciseID {
            sendAppMessage(message: [TrainingSessionAttributes.action.name: "complete",
                                     TrainingSessionAttributes.exerciseID.name: exerciseID])
        }
    }
    
    func onClickSkip() {
        isInteractaable = false
        sendAppMessage(message: [TrainingSessionAttributes.action.name: "skip"])
    }
    
    func onClickEnd() {
        isInteractaable = false
        sendAppMessage(message: [TrainingSessionAttributes.action.name: "end"])
        
        /// End Workout Session
        endWorkoutSession()
    }
}

// MARK: Watch Connectivity
extension ContentViewModel {
    func sendAppMessage(message: [String: Any]) {
        guard WCSession.default.isReachable else { return }
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
    
    func createWorkoutSession() {
        guard workoutSession == nil else { return }
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .traditionalStrengthTraining
        workoutConfiguration.locationType = .indoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            workoutSession?.prepare()
            if let startTime = startTime {
                workoutSession?.startActivity(with: startTime)
                workoutSession?.startMirroringToCompanionDevice(completion: { isSucceed, error in
                    if let error = error {
                        self.logger.log("workout session mirroring error: \(error.localizedDescription)", level: .error)
                    }
                    
                    self.logger.log("workout session mirroring is success: \(isSucceed)", level: .info)
                })
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                /// Check whether the rest time is over
                guard let restStartTime = self.restStartTime,
                        self.state == .resting else { return }
                
                if Date.now >= restStartTime.addingTimeInterval(self.restInterval) {
                    
                    /// Haptic Feedback
                    WKInterfaceDevice.current().play(.notification)
                    
                    DispatchQueue.main.async {
                        self.restStartTime = nil
                        self.restInterval = 0
                        self.state = .training
                    }
                }
            })
        } catch {
            logger.log("Error creating workout session: \(error.localizedDescription)", level: .error)
        }
    }
    
    func endWorkoutSession() {
        workoutSession?.end()
        workoutSession = nil
        
        /// End Timer
        self.timer?.invalidate()
        self.timer = nil
        
        DispatchQueue.main.async {
            self.state = .notStarted
            self.restStartTime = nil
        }
    }
}

// MARK: WKSessionDelegate
extension ContentViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        logger.log("wcsession is activated", level: .info)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        logger.log("wcsession is receievd application contenxt", level: .info)
        processContextMessage(message: applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        logger.log("wcsession is received message", level: .info)
        processContextMessage(message: message)
    }
    
    func processContextMessage(message: [String: Any]) {
        if let action = message["action"] as? String {
            if action == "end" {
                /// Stop the session
                endWorkoutSession()
            }
        }
        
        DispatchQueue.main.async {
            self.isInteractaable = true
            
            if let stateRawValue = message[TrainingSessionAttributes.state.name] as? Int, let state = TTSessionState(rawValue: stateRawValue) {
                self.state = state
                
                switch state {
                case .notStarted:
                    self.endWorkoutSession()
                case .training:
                    self.createWorkoutSession()
                default: break
                }
            }
        
            self.exerciseName = message[TrainingSessionAttributes.exerciseName.name] as? String
            self.exerciseID = message[TrainingSessionAttributes.exerciseID.name] as? String
            
            if let startTime = message[TrainingSessionAttributes.startTime.name] as? Date {
                self.startTime = startTime
            }
            
            if let weight = message[TrainingSessionAttributes.weight.name] as? Double {
                self.weight = weight
            }
            
            if let rawValue = message[TrainingSessionAttributes.weightUnit.name] as? Int, let weightUnit = WeightUnit(rawValue: rawValue) {
                self.weightUnit = weightUnit
            }
            
            if let repetitions = message[TrainingSessionAttributes.repetitions.name] as? Double {
                self.repetitions = repetitions
            }
            
            if let restStartTime = message[TrainingSessionAttributes.restStartTime.name] as? Date {
                self.restStartTime = restStartTime
            }
            
            if let restInterval = message[TrainingSessionAttributes.restInterval.name] as? TimeInterval {
                self.restInterval = restInterval
            }
            
            if let indexOfSet = message[TrainingSessionAttributes.indexOfSet.name] as? Int {
                self.indexOfSet = indexOfSet
            }
            
            if let setsProgress = message[TrainingSessionAttributes.setsProgress.name] as? Double {
                withAnimation {
                    self.setsProgress = setsProgress
                }
            }
            
            if let totoalProgress = message[TrainingSessionAttributes.totalProgress.name] as? Double {
                withAnimation {
                    self.totalProgress = totoalProgress
                }
            }
        }
    }
}

// MARK: WKExtendRuntimeSession
/**
 Suspend to use at this moment given use HKWorkoutSession instead.
 */
extension ContentViewModel: WKExtendedRuntimeSessionDelegate {
    func startExtendedRuntimeSession() {
        guard session == nil else { return }
        
        /// Initi Extended Runtime Session
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
    }
    
    func endExtendedRuntimeSession() {
        session?.invalidate()
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        logger.log("session runtime invalidate reason: \(reason)", level: .info)
        
        self.timer?.invalidate()
        self.timer = nil
        
        if let error = error {
            logger.log("extended runtime session invalidate error: \(error.localizedDescription)", level: .error)
        }
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            /// Check whether the rest time is over
            guard let restStartTime = self.restStartTime else { return }
            if Date.now >= restStartTime.addingTimeInterval(self.restInterval) {
                DispatchQueue.main.async {
                    self.restStartTime = nil
                    self.restInterval = 0
                    self.state = .training
                }
            }
        })
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        self.timer?.invalidate()
        self.timer = nil
    }
}
