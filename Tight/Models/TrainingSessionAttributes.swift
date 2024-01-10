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
        
        /// Exercise Info
        var currentExerciseID: String
        var currentExerciseName: String
        var weight: Double
        var repetition: Double
        
        /// For elapsed time
        var startTime: Date
        
        /// For rest
        var restStartTime: Date?
        var restIntervals: TimeInterval?
        
        /// For sets progress
        var indexOfSet: Int
        var currentSetsProgress: Double
        
        ///  For total  progress
        var totalExerciseCount: Int
        var currentStage: Int
        
        /// Completion
        var completionType: Int     /// 0: Abort 1: Done
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
