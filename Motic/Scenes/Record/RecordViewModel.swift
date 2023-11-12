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
    @ObservedObject var activitySessionManager: ActivitySessionManager
    @Published var isLocationBottomSheetPresented: Bool = false
    @Published var isSportSelectorPresented: Bool = false
    @Published var isWearableDeviceSelectorPresented: Bool = false
    @Published var selectedSport: SportType = .cycling
    @Published var heartRate: Double = 0.0
    @Published var sessionStatus: SessionStatus = .stop
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    var preference: UserPreference = UserPreference()
    
    
    init(dependency: RecordViewModelDependency) {
        self.dependency = dependency
        _activitySessionManager = ObservedObject(wrappedValue: dependency.activitySessionManager)
        
        // After init
        self.dependency.wearableDeviceManager.delegate = self
        selectedSport = preference.retrieveSelectedSport()
        
        // Sinks
        activitySessionManager.$currentHeartRate.sink { heartRate in
            DispatchQueue.main.async {
                self.heartRate = heartRate
            }
        }.store(in: &cancellables)
        
        activitySessionManager.$sessionStatus.sink { status in
            DispatchQueue.main.async {
                self.sessionStatus = status
            }
        }.store(in: &cancellables)
    }
    
    func validateLocationAuthorization() {
        if dependency.activitySessionManager.locationAuthorizationStatus == .denied {
            // Display the location request bottom sheet
            DispatchQueue.main.async {
                self.isLocationBottomSheetPresented.toggle()
            }
        } else if dependency.activitySessionManager.locationAuthorizationStatus == .notDetermined {
            // Ask for permission directly
            dependency.activitySessionManager.requestLocationPermission()
        }
    }
    
    func pauseSession(isReceived: Bool = false) {
        dependency.activitySessionManager.pauseSession()
        
        guard isReceived == false else { return }
        dependency.wearableDeviceManager.send(message: ["status": "pause"], replyHandler: nil)
    }
    
    func resumeSession(isReceived: Bool = false) {
        dependency.activitySessionManager.resumeSession()
        
        guard isReceived == false else { return }
        dependency.wearableDeviceManager.send(message: ["status": "resume"], replyHandler: nil)
    }
    
    func stopSession(isReceived: Bool = false) {
        dependency.activitySessionManager.stopSession()

        guard isReceived == false else { return }
        dependency.wearableDeviceManager.send(message: ["status": "stop"], replyHandler: nil)
    }
    
    func startSession(isReceived: Bool = false) {
        dependency.activitySessionManager.startSession(with: selectedSport)
        
        guard isReceived == false else { return }
        dependency.wearableDeviceManager.send(message: ["status": "start"], replyHandler: nil)
    }
}

extension RecordViewModel: WearableDeviceManagerDelegate {
    func currentSessionStatus() -> SessionStatus {
        return sessionStatus
    }
    
    func didReceived(status: SessionStatus) {
        switch status {
        case .start: startSession(isReceived: true)
        case .stop: stopSession(isReceived: true)
        case .pause: pauseSession(isReceived: true)
        case .resume: resumeSession(isReceived: true)
        }
        
        DispatchQueue.main.async {
            self.sessionStatus = status
        }
        dependency.logger.log("record view recived status: \(status)", level: .debug)
    }
    
    func didReceived(heartRate: Double) {
        dependency.logger.log("[iPhone] record view received heart rate: \(heartRate)", level: .debug)
        
        DispatchQueue.main.async {
            self.heartRate = heartRate
        }
    }
}
    
