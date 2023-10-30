//
//  ConnectivityProvider.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/14.
//

import WatchConnectivity
import SwiftUI

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

protocol WatchConnectivityProviderDelegate: AnyObject {
    func connectivityStatusChanged(isReachable: Bool)
    func didReceived(status: SessionStatus)
    func currentSessionStatus() -> SessionStatus
}

class WatchConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    private let session: WCSession
    private let logger: CustomLogger
    @Published var isReacable: Bool = false
    
    weak var delegate: WatchConnectivityProviderDelegate?

    init(session: WCSession = .default, logger: CustomLogger) {
        self.session = session
        self.logger = logger
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func send(message: [String:Any], replyHandler: (([String: Any]) -> Void)?) -> Void {        
        if session.isReachable {
            session.sendMessage(message, replyHandler: replyHandler) { (error) in
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let status = message["status"] as? String {
            let sessionStatus = SessionStatus(status: status)
            delegate?.didReceived(status: sessionStatus)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let request = message["request"] as? String,
            request == "currentSessionStatus",
           let status = delegate?.currentSessionStatus() {
            replyHandler(["currentStatus": status.rawValue])
        }
    }
}
