//
//  ConnectivityProvider.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/14.
//

import WatchConnectivity
import SwiftUI

class WatchConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    private let session: WCSession
    @Published var isReacable: Bool = false

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func send(message: [String:Any], replyHandler: (([String: Any]) -> Void)?) -> Void {        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: replyHandler) { (error) in
                print(error.localizedDescription)
            }
        }
        else {
            print("session is not reachable")
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        isReacable = activationState == .activated
        print("isReachable: \(activationState == .activated)")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    }
}
