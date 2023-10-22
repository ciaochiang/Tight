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
    }
    
    func onTapPlayButton() {
        isRecording.toggle()
        dependency.connectivity.send(message: ["status": "start"], replyHandler: nil)
    }
    
    func onTapPauseButton() {
        isPaused.toggle()
        if isPaused == true {
            dependency.connectivity.send(message: ["status": "pause"], replyHandler: nil)
        } else {
            dependency.connectivity.send(message: ["status": "resume"], replyHandler: nil)
        }
    }
    
    func onTapStopButton() {
        isRecording = false
        dependency.connectivity.send(message: ["status": "stop"], replyHandler: nil)
    }
}

extension MainViewModel: WatchConnectivityProviderDelegate {
    func didReceived(status: SessionStatus) {
        dependency.logger.log("Main viewmodel received status: \(status)")
    }
}
