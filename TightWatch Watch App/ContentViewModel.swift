//
//  ContentViewModel.swift
//  TightWatch Watch App
//
//  Created by Ciao Chiang on 2024/1/21.
//

import Foundation
import SwiftUI
import WatchConnectivity

class ContentViewModel: NSObject, ObservableObject {
    @Published var state: TrainingSessionState = .notStarted
    @Published var currentExerciseID: String?
    @Published var exerciseName: String?
    @Published var startTime: Date?
    @Published var weight: Double?
    @Published var weightUnit: Int?
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
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
            
            if let weightUnit = message["weightUnit"] as? Int {
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
