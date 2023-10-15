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
    var wearableDeviceManager: WearableDeviceManager { get }
}

class RecordViewModelDependencyImp: RecordViewModelDependency {
    var logger: Logger
    var activitySessionManager: ActivitySessionManager
    var wearableDeviceManager: WearableDeviceManager
    
    init(logger: Logger,
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
    }
    
    func resumeSession() {
        dependency.activitySessionManager.resumeSession()
    }
    
    func stopSession() {
        dependency.activitySessionManager.stopSession()
    }
    
    func startSession() {
        dependency.activitySessionManager.startSession(with: selectedSport)
    }
}
