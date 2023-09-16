//
//  MessageViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import WatchConnectivity

class MessageViewModel: NSObject, ObservableObject {
  @Published var heartRate: Double = 0.0
  
  override init() {
    super.init()
    
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
  }
}

extension MessageViewModel: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
      // Handle the received message
      if let heartRate = message["heartRate"] as? Double {
          DispatchQueue.main.async {
//              self.receivedMessage = heartRate
            self.heartRate = heartRate
            print("iphone receiver: \(String(heartRate)) bpm")
          }
      }
  }
}
