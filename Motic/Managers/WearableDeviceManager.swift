//
//  WearableDeviceManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/14.
//

import SwiftUI
import WatchConnectivity

enum WearableDeviceType {
    case apple
    case garmin
}

struct WearableDevice: Hashable, Identifiable {
    let id: String = UUID().uuidString
    var type: WearableDeviceType
}

enum SessionStatus: Int {
    case start
    case pause
    case resume
    case stop
    
    init(status: String) {
        switch status {
        case "start": self = .start
        case "pause": self = .pause
        case "resume": self = .resume
        case "stop": self = .stop
        default: self = .stop
        }
    }
}

protocol WearableDeviceManagerDelegate: AnyObject {
    func didReceived(status: SessionStatus)
    func didReceived(heartRate: Double)
    func currentSessionStatus() -> SessionStatus
}

class WearableDeviceManager: NSObject, ObservableObject {
    private var logger: CustomLogger
    @Published var isDeviceConnected: Bool = false
    @Published var registeredDevices: [WearableDevice] = []
    @Published var connectedDevice: WearableDevice?
    weak var delegate: WearableDeviceManagerDelegate?
        
    init(logger: CustomLogger) {
        self.logger = logger
        super.init()
        
        // Retreieve registered devices
        registeredDevices = retrieveRegisteredDevices()
        
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
            logger.log("session is not reachable", level: .debug)
        }
    }
}

// MARK: WCSessionDelegate
extension WearableDeviceManager: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.log("Watch session become invctive", level: .info)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger.log("Watch session did deactivate", level: .info)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        isDeviceConnected = activationState == .activated
        logger.log("Watch activation complete with state: \(activationState)", level: .info)
        
        if let error = error {
            logger.log("Watch activation error: \(error.localizedDescription)", level: .error)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let status = message["status"] as? String {
            let sessionStatus = SessionStatus(status: status)
            delegate?.didReceived(status: sessionStatus)
        } else if let heartRate = message["heartRate"] as? Double {
            delegate?.didReceived(heartRate: heartRate)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {        
        if let request = message["request"] as? String, request == "fetchSports" {
            // reply all sports
            let sports = SportType.allCases.map { ["id": $0.rawValue, "description": $0.description] as [String : Any] }
            replyHandler(["reply": sports])
        }
        else if let request = message["request"] as? String,
                request == "currentSessionStatus",
                let status = delegate?.currentSessionStatus() {
            replyHandler(["currentStatus": status.rawValue])
        }
    }
}
