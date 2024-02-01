//
//  LiveActivityAttributes.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/6.
//

import Foundation
import ActivityKit

struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var state: Int
        var startTime: Date
        
        /// Exercise Info
        var currentExerciseID: String
        var exerciseName: String
        var weight: Double
        var weightUnit: Int
        var repetitions: Double
        
        /// Rest Time
        var restStartTime: Date
        var restInterval: TimeInterval
        
        /// Progress
        var indexOfSet: Int
        var setsProgress: Double
        var totalProgress: Double
        
        func keyValuePairs() -> [String: Any] {
            var keyValuePairs = [String: Any]()
                
            let mirror = Mirror(reflecting: self)
            for (label, value) in mirror.children {
                if let label = label {
                    keyValuePairs[label] = value
                }
            }
            
            return keyValuePairs
        }
    }
}
