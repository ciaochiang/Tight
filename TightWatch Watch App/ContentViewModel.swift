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
    @Published var state: TrainingSessionState = .notStarted
    @Published var currentExerciseID: String?
    @Published var exerciseName: String?
    @Published var startTime: Date?
    @Published var weight: Double?
    @Published var weightUnit: WeightUnit?
    @Published var repetitions: Double?
    
    /// For rest
    @Published var restStartTime: Date?
    @Published var restIntervals: TimeInterval?
    
    /// For sets progress
    @Published var indexOfSet: Int?
    @Published var currentSetsProgress: Double?
    
    ///  For total  progress
    @Published var totoalProgress: Double?
    
    @Published var isInteractaable: Bool = true
    
    /// Health Kit
    let healthStore = HKHealthStore()
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
        sendAppMessage(message: ["action": "complete"])
    }
    
    func onClickSkip() {
        isInteractaable = false
        sendAppMessage(message: ["action": "skip"])
    }
    
    func onClickEnd() {
        isInteractaable = false
        sendAppMessage(message: ["action": "end"])
        
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
                        print("workout session mirroring error: \(error.localizedDescription)")
                    }
                    
                    print("workout session mirroring is success: \(isSucceed)")
                })
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                /// Check whether the rest time is over
                guard let restStartTime = self.restStartTime, let restIntervals = self.restIntervals else { return }
                if Date.now >= restStartTime.addingTimeInterval(restIntervals) {
                    DispatchQueue.main.async {
                        self.restStartTime = nil
                        self.restIntervals = nil
                        self.state = .training
                    }
                }
            })
        } catch {
            print("Error creating workout session: \(error.localizedDescription)")
        }
    }
    
    func endWorkoutSession() {
        workoutSession?.end()
        workoutSession = nil
        
        /// End Timer
        self.timer?.invalidate()
        self.timer = nil
    }
}

// MARK: WKSessionDelegate
extension ContentViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("did activate")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        processContextMessage(message: applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        processContextMessage(message: message)
    }
    
    func processContextMessage(message: [String: Any]) {
        DispatchQueue.main.async {
            self.isInteractaable = true
            
            if let stateRawValue = message["state"] as? Int, let state = TrainingSessionState(rawValue: stateRawValue) {
                self.state = state
                
                switch state {
                case .training:  
                    self.createWorkoutSession()
                case .aborted, .finshed:
                    self.endWorkoutSession()
                default: break
                }
            }
            
            if let currentExerciseID = message["currentExerciseID"] as? String {
                self.currentExerciseID = currentExerciseID
            }
            
            if let exerciseName = message["exerciseName"] as? String {
                self.exerciseName = exerciseName
            }
            
            if let startTime = message["startTime"] as? Date {
                self.startTime = startTime
            }
            
            if let weight = message["weight"] as? Double {
                self.weight = weight
            }
            
            if let rawValue = message["weightUnit"] as? Int, let weightUnit = WeightUnit(rawValue: rawValue) {
                self.weightUnit = weightUnit
            }
            
            if let repetitions = message["repetitions"] as? Double {
                self.repetitions = repetitions
            }
            
            if let restStartTime = message["restStartTime"] as? Date {
                self.restStartTime = restStartTime
            }
            
            if let restIntervals = message["restIntervals"] as? TimeInterval {
                self.restIntervals = restIntervals
            }
            
            if let indexOfSet = message["indexOfSet"] as? Int {
                self.indexOfSet = indexOfSet
            }
            
            if let currentSetsProgress = message["currentSetsProgress"] as? Double {
                withAnimation {
                    self.currentSetsProgress = currentSetsProgress
                }
            }
            
            if let totoalProgress = message["totoalProgress"] as? Double {
                self.totoalProgress = totoalProgress
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
        print("session runtime invalidate reason: \(reason)")
        
        self.timer?.invalidate()
        self.timer = nil
        
        if let error = error {
            print("extended runtime session invalidate error: \(error.localizedDescription)")
        }
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            /// Check whether the rest time is over
            guard let restStartTime = self.restStartTime, let restIntervals = self.restIntervals else { return }
            if Date.now >= restStartTime.addingTimeInterval(restIntervals) {
                DispatchQueue.main.async {
                    self.restStartTime = nil
                    self.restIntervals = nil
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
