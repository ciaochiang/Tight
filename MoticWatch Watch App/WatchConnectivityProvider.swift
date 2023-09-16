//
//  ConnectivityProvider.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/14.
//

import WatchConnectivity

class WatchConnectivityProvider: NSObject, WCSessionDelegate {
    
  private let session: WCSession
    
  init(session: WCSession = .default) {
    self.session = session
    super.init()
    self.session.delegate = self
    self.session.activate()
  }
    
  func send(message: [String:Any]) -> Void {
    session.sendMessage(message, replyHandler: nil) { (error) in
      print(error.localizedDescription)
    }
  }
    
  func session(_ session: WCSession,
               activationDidCompleteWith activationState: WCSessionActivationState,
               error: Error?) {
  }
}
