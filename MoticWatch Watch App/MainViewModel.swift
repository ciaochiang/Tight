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
    
    init(dependency: MainViewModelDependency) {
        self.dependency = dependency
        self.dependency.connectivity.delegate = self
    }
}

extension MainViewModel: WatchConnectivityProviderDelegate {
    func didReceived(status: SessionStatus) {
        dependency.logger.log("Main viewmodel received status: \(status)")
    }
}
