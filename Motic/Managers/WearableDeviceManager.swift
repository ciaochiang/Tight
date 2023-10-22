//
//  WearableDeviceManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/14.
//

import SwiftUI
import WatchConnectivity

protocol WearableDeviceManagerDependency {
    var logger: CustomLogger { get }
}

class WearableDeviceManagerDependencyImp: WearableDeviceManagerDependency {
    var logger: CustomLogger
    
    init(logger: CustomLogger) {
        self.logger = logger
    }
}

enum WearableDeviceType {
    case apple
    case garmin
}

struct WearableDevice: Hashable, Identifiable {
    let id: String = UUID().uuidString
    var type: WearableDeviceType
}

class WearableDeviceManager: NSObject, ObservableObject {
    var dependency: WearableDeviceManagerDependency
    @Published var isDeviceConnected: Bool = false
    @Published var registeredDevices: [WearableDevice] = []
    @Published var connectedDevice: WearableDevice?
        
    init(dependency: WearableDeviceManagerDependency) {
        self.dependency = dependency
        super.init()
        
        // Retreieve registered devices
        registeredDevices = registeredDevices
        
        isDeviceConnected = activateDeviceIfApplicable()
    }
    
    func retrieveRegisteredDevices() -> [WearableDevice] {
        return []
    }
    
    func activateDeviceIfApplicable() -> Bool {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            
            return WCSession.default.isReachable
        }
        
        return false
    }
    
    /**
     Apple Watch Only
     */
    func send(message: [String:Any], replyHandler: (([String: Any]) -> Void)?) -> Void {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: replyHandler) { (error) in
                print(error.localizedDescription)
            }
        }
        else {
            dependency.logger.log("session is not reachable", level: .debug)
        }
    }
}

// MARK: WCSessionDelegate
extension WearableDeviceManager: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        dependency.logger.log("Watch session become invctive", level: .info)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        dependency.logger.log("Watch session did deactivate", level: .info)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        isDeviceConnected = activationState == .activated
        dependency.logger.log("Watch activation complete with state: \(activationState)", level: .info)
        
        if let error = error {
            dependency.logger.log("Watch activation error: \(error.localizedDescription)", level: .error)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        dependency.logger.log("Received message from watch: \(message)", level: .info)
    }
}
