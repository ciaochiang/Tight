//
//  MoticWatchApp.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI

@main
struct MoticWatch_Watch_AppApp: App {
    private var logger = CustomLogger()
    
    var body: some Scene {
        WindowGroup {
            let connectivity = WatchConnectivityProvider(logger: logger)
            let sportProvider = SportProvider(connectivity: connectivity)
            let dependency = SportSelectorViewModelDependencyImp(logger: logger, sportProvider: sportProvider)
            let viewModel = SportSelectorViewModel(dependency: dependency)
            SportSelectorView(viewModel: viewModel, logger: logger)
        }
    }
}
