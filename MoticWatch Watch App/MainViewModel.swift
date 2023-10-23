//
//  MainViewModel.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/22.
//

import SwiftUI

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
    
    init(dependency: MainViewModelDependency) {
        self.dependency = dependency
        self.dependency.connectivity.delegate = self
        self.dependency.workoutSessionManager.delegate = self
    }
    
    func onTapPlayButton(isReceived: Bool = false) {
        isRecording.toggle()
        
        // Start monitoring heart rate
        dependency.workoutSessionManager.startHeartRateMonitoring()
        
        guard isReceived == false else { return }
        dependency.connectivity.send(message: ["status": "start"], replyHandler: nil)
    }
    
    func onTapPauseButton(isReceived: Bool = false) {
        isPaused.toggle()
        
        guard isReceived == false else { return }
        if isPaused == true {
            dependency.connectivity.send(message: ["status": "pause"], replyHandler: nil)
        } else {
            dependency.connectivity.send(message: ["status": "resume"], replyHandler: nil)
        }
    }
    
    func onTapStopButton(isReceived: Bool = false) {
        isRecording = false
        
        guard isReceived == false else { return }
        dependency.connectivity.send(message: ["status": "stop"], replyHandler: nil)
    }
}

extension MainViewModel: WatchConnectivityProviderDelegate {
    func didReceived(status: SessionStatus) {
        switch status {
        case .start: onTapPlayButton(isReceived: true)
        case .stop: onTapStopButton(isReceived: true)
        case .pause: onTapPauseButton(isReceived: true)
        case .resume: onTapPlayButton(isReceived: true)
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
