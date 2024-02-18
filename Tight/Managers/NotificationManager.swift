//
//  NotificationManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    @Published var isGranted: Bool = false
    private var logger = TTLogger()
  
    func requestNotificationAuthorization(completion: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                self.isGranted = granted
                self.logger.log("Notification permission granted.", level: .info)
            } else if let error = error {
                self.logger.log(error.localizedDescription, level: .error)
            } else {
                self.logger.log("Notification permission denied.", level: .info)
            }
              
            completion(true)
        }
    }
}
