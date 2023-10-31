//
//  MoticWatchApp.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI

@main
struct MoticWatch_Watch_AppApp: App {
    private var logger: CustomLogger
    @StateObject private var connectivity: WatchConnectivityProvider
    
    init() {
        self.logger = CustomLogger()
        let connectivityProvider = WatchConnectivityProvider(logger: logger)
        _connectivity = StateObject(wrappedValue: connectivityProvider)
    }

    var body: some Scene {
        WindowGroup {
            if connectivity.isReacable {
                TabView {
                    let workoutSessionManager = WorkoutSessionManager()
                    let mainViewDependency = MainViewModelDependencyImp(logger: logger,
                                                                        connectivity: connectivity,
                                                                        workoutSessionManager: workoutSessionManager)
                    let mainViewModel = MainViewModel(dependency: mainViewDependency)
                    MainView(viewModel: mainViewModel)
                    
                    let sportProvider = SportProvider(connectivity: connectivity)
                    let sportSelectorViewDependency = SportSelectorViewModelDependencyImp(logger: logger, sportProvider: sportProvider)
                    let sportSelectorViewModel = SportSelectorViewModel(dependency: sportSelectorViewDependency)
                    SportSelectorView(viewModel: sportSelectorViewModel, logger: logger)
                }
            } else {
                Text("Require connect to iPhone")
            }
        }
    }
}
