//
//  TraningSessionManager+Notification.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/29.
//

import Foundation
import UserNotifications

// MARK: Local Notification
extension TrainingSessionManager {
    func scheduleNotification(timeInterval: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = LocalizationProvider.notificationRestTimeDoneTitle.stringValue
                content.body = LocalizationProvider.notificationRestTimeDoneDescription.stringValue
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "soundEffect.m4a"))
                content.interruptionLevel = .timeSensitive
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
                let request = UNNotificationRequest(identifier: Constants.NOTIFICATION_IDENTIFIER_TRAINING_SESSION, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request) { (error) in
                    if let error = error {
                        // Handle any errors here.
                        self.logger.log(error.localizedDescription, level: .error)
                    }
                }
            }
            else if let error = error {
                // Handle the case where permission is denied or there is an error.
                self.logger.log(error.localizedDescription, level: .error)
            }
        }
    }
    
    func cancelScheduledNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Constants.NOTIFICATION_IDENTIFIER_TRAINING_SESSION])
    }
}
