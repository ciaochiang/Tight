//
//  MainViewModel.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/22.
//

import SwiftUI
import Combine

protocol MainViewModelDependency {
    var logger: CustomLogger { get }
    var connectivity: WatchConnectivityProvider { get }
    var workoutSessionManager: WorkoutSessionManager { get }
}

class MainViewModelDependencyImp: MainViewModelDependency {
    var logger: CustomLogger
    var connectivity: WatchConnectivityProvider
    var workoutSessionManager: WorkoutSessionManager
    
    init(logger: CustomLogger,
         connectivity: WatchConnectivityProvider,
         workoutSessionManager: WorkoutSessionManager) {
        self.logger = logger
        self.connectivity = connectivity
        self.workoutSessionManager = workoutSessionManager
    }
}

class MainViewModel: ObservableObject {
    var dependency: MainViewModelDependency
    @Published var isRecording: Bool = false
    @Published var isPaused: Bool = false
    @Published var sessionStatus: SessionStatus = .stop
    
    @ObservedObject var connectivity: WatchConnectivityProvider
    @Published var sessionIsReachable: Bool = false
    @State private var cancellables: Set<AnyCancellable> = []

    
    init(dependency: MainViewModelDependency) {
        self.dependency = dependency
        _connectivity = ObservedObject(wrappedValue: dependency.connectivity)
        
        self.dependency.connectivity.delegate = self
        self.dependency.workoutSessionManager.delegate = self
        
        // Sinks
        connectivity.$isReacable.sink { isReachable in
//            self.syncSessionStatus()
            self.dependency.logger.log("[Watch] session reachability is \(isReachable)", level: .debug)
        }.store(in: &cancellables)
    }
    
    func onTapPlayButton(isReceived: Bool = false) {
        guard sessionStatus == .stop else { return }
        
        syncSessionStatus()
        DispatchQueue.main.async {
            self.isRecording = true
            self.isPaused = false
            self.sessionStatus = .start
        }
        
        // Start monitoring heart rate
        dependency.workoutSessionManager.startHeartRateMonitoring()
        
        // Send message to iPhone
        guard isReceived == false else { return }
        dependency.connectivity.send(message: ["status": "start"], replyHandler: nil)
    }
    
    func onTapPauseButton(isReceived: Bool = false) {
        let ableToPause = sessionStatus == .start || sessionStatus == .resume
        let status: SessionStatus = ableToPause ? .pause : .resume
        let message = ableToPause ? ["status": "pause"] : ["status": "resume"]
        DispatchQueue.main.async {
            self.isRecording = status == .resume
            self.isPaused = status == .pause
            self.sessionStatus = status
        }
        
        // Send message to iPhone
        guard isReceived == false else { return }
        dependency.connectivity.send(message: message, replyHandler: nil)
    }
    
    func onTapStopButton(isReceived: Bool = false) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.isPaused = false
            self.sessionStatus = .stop
        }
        
        // Stop heart rate monitoring
        dependency.workoutSessionManager.stopHeartRateMonitoring()
        
        // Send message to iPhone
        guard isReceived == false else { return }
        dependency.connectivity.send(message: ["status": "stop"], replyHandler: nil)
    }
    
    func syncSessionStatus() {
        connectivity.send(message: ["request": "currentSessionStatus"]) { response in
            if let statusValue = response["currentStatus"] as? Int,
                let status = SessionStatus(rawValue: statusValue) {
                DispatchQueue.main.async {
                    self.sessionStatus = status
                    self.dependency.logger.log("[Watch] Sync session status: \(response)", level: .debug)
                }
            }
        }
    }
}

extension MainViewModel: WatchConnectivityProviderDelegate {
    func connectivityStatusChanged(isReachable: Bool) {

    }
    
    func currentSessionStatus() -> SessionStatus {
        return sessionStatus
    }
    
    func didReceived(status: SessionStatus) {
        switch status {
        case .start: onTapPlayButton(isReceived: true)
        case .stop: onTapStopButton(isReceived: true)
        case .pause: onTapPauseButton(isReceived: true)
        case .resume: onTapPauseButton(isReceived: true)
        }
        dependency.logger.log("Main viewmodel received status: \(status)")
    }
}

extension MainViewModel: WorkoutSessionManagerDelegate {
    func didReceived(heartRate: Double) {
        dependency.logger.log("Heart Rate: \(heartRate)", level: .debug)
        
        // Send to iPhone
        dependency.connectivity.send(message: ["heartRate": heartRate], replyHandler: nil)
    }
}
