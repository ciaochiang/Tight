//
//  MoticWatchApp.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI

@main
struct MoticWatch_Watch_AppApp: App {
    private var logger = Logger(configuration: AppConfiguration.loggerConfig)
    var body: some Scene {
        WindowGroup {
            let connectivity = WatchConnectivityProvider()
            let sportProvider = SportProvider(connectivity: connectivity)
            let dependency = SportSelectorViewModelDependencyImp(logger: logger, sportProvider: sportProvider)
            let viewModel = SportSelectorViewModel(dependency: dependency)
            SportSelectorView(viewModel: viewModel)
        }
    }
}
