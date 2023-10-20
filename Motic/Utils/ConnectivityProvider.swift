//
//  Connectivity.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import WatchConnectivity

class ConnectivityProvider: NSObject, ObservableObject {
    var session: WCSession?
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = .default
            session?.delegate = self
            session?.activate()
        }
    }
}

extension ConnectivityProvider: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
      
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
      
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
      
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Handle the received message
        print("reived ")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Message: \(message)")
        
        if let request = message["request"] as? String, request == "fetchSports" {
            // reply all sports
            let sports = SportType.allCases.map { ["id": $0.rawValue, "description": $0.description] as [String : Any] }
            replyHandler(["reply": sports])
        }
        
    }
}
