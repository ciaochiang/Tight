//
//  RecordViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/28.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine

protocol RecordViewModelDependency {
    var logger: Logger { get }
    var activitySessionManager: ActivitySessionManager { get }
}

class RecordViewModelDependencyImp: RecordViewModelDependency {
    var logger: Logger
    var activitySessionManager: ActivitySessionManager
    
    init(logger: Logger, activitySessionManager: ActivitySessionManager) {
        self.logger = logger
        self.activitySessionManager = activitySessionManager
    }
}

class RecordViewModel: ObservableObject {
    var dependency: RecordViewModelDependency
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(dependency: RecordViewModelDependency) {
        self.dependency = dependency
    }
}
