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
        var currentExerciseID: String
        var currentExercise: String
        var totalSetsCount: Int
        var indexOfSet: Int
        var weight: Double
        var repetition: Double
        var restIntervals: TimeInterval
        var elapsedTime: TimeInterval
        var completionMessage: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
