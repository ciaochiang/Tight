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
    var logger: CustomLogger { get }
    var activitySessionManager: ActivitySessionManager { get }
    var wearableDeviceManager: WearableDeviceManager { get }
}

class RecordViewModelDependencyImp: RecordViewModelDependency {
    var logger: CustomLogger
    var activitySessionManager: ActivitySessionManager
    var wearableDeviceManager: WearableDeviceManager
    
    init(logger: CustomLogger,
         activitySessionManager: ActivitySessionManager,
         wearableDeviceManager: WearableDeviceManager) {
        self.logger = logger
        self.activitySessionManager = activitySessionManager
        self.wearableDeviceManager = wearableDeviceManager
    }
}

class RecordViewModel: ObservableObject {
    var dependency: RecordViewModelDependency
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var isLocationBottomSheetPresented: Bool = false
    @Published var isSportSelectorPresented: Bool = false
    @Published var isWearableDeviceSelectorPresented: Bool = false
    @Published var selectedSport: SportType = .cycling
    
    var preference: UserPreference = UserPreference()
    
    init(dependency: RecordViewModelDependency) {
        self.dependency = dependency
        
        selectedSport = preference.retrieveSelectedSport()
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
    
    func pauseSession() {
        dependency.activitySessionManager.pauseSession()
        dependency.wearableDeviceManager.send(message: ["status": "pause"], replyHandler: nil)
    }
    
    func resumeSession() {
        dependency.activitySessionManager.resumeSession()
        dependency.wearableDeviceManager.send(message: ["status": "resume"], replyHandler: nil)
    }
    
    func stopSession() {
        dependency.activitySessionManager.stopSession()
        dependency.wearableDeviceManager.send(message: ["status": "stop"], replyHandler: nil)
    }
    
    func startSession() {
        dependency.activitySessionManager.startSession(with: selectedSport)
        dependency.wearableDeviceManager.send(message: ["status": "start"], replyHandler: nil)
    }
}
