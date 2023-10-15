//
//  WearableDeviceManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/14.
//

import SwiftUI
import WatchConnectivity

protocol WearableDeviceManagerDependency {
    var logger: Logger { get }
}

class WearableDeviceManagerDependencyImp: WearableDeviceManagerDependency {
    var logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
}

class WearableDeviceManager: NSObject, ObservableObject {
    var dependency: WearableDeviceManagerDependency
    
    @Published var isAppleWatchConnected: Bool = false
    
    init(dependency: WearableDeviceManagerDependency) {
        self.dependency = dependency
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        isAppleWatchConnected = WCSession.default.isReachable
        dependency.logger.log("\(isAppleWatchConnected)", level: .info)
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
        isAppleWatchConnected = activationState == .activated
        dependency.logger.log("Watch activation complete with state: \(activationState)", level: .info)
        
        if let error = error {
            dependency.logger.log("Watch activation error: \(error.localizedDescription)", level: .error)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        dependency.logger.log("Received message from watch: \(message)", level: .info)
    }
}
