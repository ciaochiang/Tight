//
//  AnalyticsHelper.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/14.
//

import Foundation
import FirebaseAnalytics

class AnalyticsHelper {
    static func logScreen(screenName: String, screenClass: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass
        ])
    }
    
    static func logEvent(eventName: String, parameters: [String: Any]?) {
        Analytics.logEvent(eventName, parameters: parameters)
    }
}
