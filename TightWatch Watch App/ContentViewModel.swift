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
    @Published var exerciseName: String?
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
            print("Error creating workout session: \(error.localizedDescription)")
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
        print("did activate")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        processContextMessage(message: applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
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
            
            if let stateRawValue = message[TraningSessionAttributes.state.name] as? Int, let state = TrainingSessionState(rawValue: stateRawValue) {
                self.state = state
                
                switch state {
                case .notStarted:
                    self.endWorkoutSession()
                case .training:
                    self.createWorkoutSession()
                default: break
                }
            }
            
            if let exerciseName = message[TraningSessionAttributes.exerciseName.name] as? String {
                self.exerciseName = exerciseName
            }
            
            if let startTime = message[TraningSessionAttributes.startTime.name] as? Date {
                self.startTime = startTime
            }
            
            if let weight = message[TraningSessionAttributes.weight.name] as? Double {
                self.weight = weight
            }
            
            if let rawValue = message[TraningSessionAttributes.weightUnit.name] as? Int, let weightUnit = WeightUnit(rawValue: rawValue) {
                self.weightUnit = weightUnit
            }
            
            if let repetitions = message[TraningSessionAttributes.repetitions.name] as? Double {
                self.repetitions = repetitions
            }
            
            if let restStartTime = message[TraningSessionAttributes.restStartTime.name] as? Date {
                self.restStartTime = restStartTime
            }
            
            if let restInterval = message[TraningSessionAttributes.restInterval.name] as? TimeInterval {
                self.restInterval = restInterval
            }
            
            if let indexOfSet = message[TraningSessionAttributes.indexOfSet.name] as? Int {
                self.indexOfSet = indexOfSet
            }
            
            if let setsProgress = message[TraningSessionAttributes.setsProgress.name] as? Double {
                withAnimation {
                    self.setsProgress = setsProgress
                }
            }
            
            if let totoalProgress = message[TraningSessionAttributes.totalProgress.name] as? Double {
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
