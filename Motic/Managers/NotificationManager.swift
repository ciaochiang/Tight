//
//  NotificationManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
  @Published var isGranted: Bool = false
  
  func requestNotificationAuthorization(completion: @escaping (Bool) -> ()) {
    #if DEBUG
    completion(true)
    return
    #else
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
      if granted {
        print("Notification permission granted.")
        self.isGranted = granted
      } else if let error = error {
        print("Notification permission error: \(error)")
      } else {
        print("Notification permission denied.")
      }
      
      completion(true)
    }
    #endif
  }
}
