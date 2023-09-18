//
//  Connectivity.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import WatchConnectivity

class ConnectivityProvider: NSObject, ObservableObject {
  override init() {
    super.init()
    
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
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
  }
}
