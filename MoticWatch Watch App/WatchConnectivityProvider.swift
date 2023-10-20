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
    private let logger: CustomLogger
    @Published var isReacable: Bool = false

    init(session: WCSession = .default, logger: CustomLogger) {
        self.session = session
        self.logger = logger
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
            logger.log("session is not reachable", level: .debug)
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        isReacable = activationState == .activated
        logger.log("[connectivity] isReachable: \(activationState == .activated)", level: .debug)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    }
}
