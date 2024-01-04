//
//  TrainingSessionAttributes.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/6.
//

import Foundation
import ActivityKit

struct TrainingSessionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var totalExerciseCount: Int
        var currentStage: Int
        var currentExercise: String
        var nextExercise: String
        var weight: Double
        var repetition: Double
        var restInterval: TimeInterval
        var elapsedTime: TimeInterval
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
