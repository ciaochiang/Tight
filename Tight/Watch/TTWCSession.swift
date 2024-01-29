//
//  TTWCSession.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/29.
//

import Foundation
import WatchConnectivity

class TTWCSession {
    static let shared = TTWCSession()
    
    func sendMessage(_ message: [TraningSessionAttributes: Any]) {
        guard WCSession.default.isReachable else { return }
        
        let convertedMessage = message.reduce(into: [String: Any]()) { (result, entry) in
            let (key, value) = entry
            result[key.name] = value
        }
        
        WCSession.default.sendMessage(convertedMessage, replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
    
    func updateApplicationContext(_ message: [TraningSessionAttributes: Any]) {
        do {            
            let convertedMessage = message.reduce(into: [String: Any]()) { (result, entry) in
                let (key, value) = entry
                result[key.name] = value
            }
            try WCSession.default.updateApplicationContext(convertedMessage)
        } catch {
            print(error.localizedDescription)
        }
    }
}
