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
    @Published var isLocationBottomSheetPresented: Bool = false
    
    init(dependency: RecordViewModelDependency) {
        self.dependency = dependency
    }
    
    func validateLocationAuthorization() {
        if dependency.activitySessionManager.locationAuthorizationStatus == .denied {
            // Display the location request bottom sheet
            DispatchQueue.main.async {
                self.isLocationBottomSheetPresented.toggle()
            }
        } else if dependency.activitySessionManager.locationAuthorizationStatus == .notDetermined {
            // Ask for permission directly
            dependency.activitySessionManager.locationManager.requestAlwaysAuthorization()
        }
    }
}
