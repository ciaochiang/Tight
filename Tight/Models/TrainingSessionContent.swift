//
//  TrainingSessionContent.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/1.
//

import Foundation
import SwiftData

struct TrainingSessionContent: Codable {
    var state: TTSessionState = .notStarted
    
    /// Stores the unique identifier of a live activity.
    ///
    /// The `liveActivityID` property is used to hold the unique identifier (ID) associated with a live activity or event. This ID can be utilized to uniquely identify and reference the live activity within your application.
    ///
    /// - Note: Initially, this property is set to an empty string (""). Ensure that it is assigned a valid ID when relevant.
    var liveActivityID: String = ""
    
    /// Represents the currently active or arranged exercise in the training session.
    ///
    /// The `currentExercise` property holds an instance of `ArrangedExercise`, which represents the exercise that is currently being performed or is scheduled to be performed next in the training session.
    ///
    /// - Note: This property may be `nil` if there are no exercises currently active or arranged in the session.
    var currentExercise: ArrangedExercise?
    var exerciseID: String?
    
    /// Training session's start time
    var startTime: Date?
    
    /// The total number of exercises in the training session.
    var exerciseCount: Int = 0
    
    /// Current stage of whole training session
    var indexOfExercise: Int = 0
    
    /// Current progress value of training session
    var totalProgress: Double = 0.0
    
    /// The index indicating the current set of exercises within the training session.
    ///
    /// This property represents the set of exercises currently being performed in a training session.
    /// It starts at 0 for the first set and increments as the session progresses through different sets.
    /// - Note: The value of this property should be non-negative.
    var indexOfSet: Int = 0
    
    /// The percentage completion of sets in the current exercise.
    ///
    /// This property calculates the completion percentage based on the formula:
    /// `exerciseSetCompletionPercentage = Double(exerciseSetIndex) / Double(exercise.sets)`
    ///
    /// - Note: The value of this property ranges from 0.0 (no sets completed) to 1.0 (all sets completed).
    var setsProgress: Double = 0.0
    
    // MARK: Rest Time Properties
    /// Represents the start time of a rest interval during a training session.
    ///
    /// The `restStartTime` property stores the timestamp indicating the start time of a rest period. It is `nil` when there is no ongoing rest period.
    var restStartTime: Date?
    
    /// Represents the duration of rest intervals during a training session.
    ///
    /// The `restIntervals` property stores the duration, in seconds, of each rest interval. It is `nil` when there are no scheduled rest intervals.
    var restInterval: Double = 0.0
    
    
    func currentExerciseRestInterval() -> Double {
        if let restInterval = currentExercise?.restIntevals {
            return restInterval.isNaN ? 0 : restInterval
        }
        else {
            return 0
        }
    }
    
    mutating func setCurrentExercise(_ exercise: ArrangedExercise) {
        currentExercise = exercise
        exerciseID = exercise.id.uuidString
    }
    
    mutating func setIndexOfSet(index: Int) {
        indexOfSet = index
        
        /// Update sets progress
        setsProgress = Double(index) / Double(currentExercise?.sets ?? 0)
    }
    
    mutating func setIndexOfExercise(index: Int) {
        indexOfExercise = index
        
        /// Update total progress
        totalProgress = Double(index) / Double(exerciseCount)
    }
    
    init(state: TTSessionState = .notStarted,
         liveActivityID: String = "",
         currentExercise: ArrangedExercise? = nil,
         exerciseID: String? = nil,
         startTime: Date? = nil,
         exerciseCount: Int = 0,
         indexOfExercise: Int = 0,
         totalProgress: Double = 0,
         indexOfSet: Int = 0,
         setsProgress: Double = 0,
         restStartTime: Date? = nil,
         restInterval: Double = 0) {
        
        self.state = state
        self.liveActivityID = liveActivityID
        self.currentExercise = currentExercise
        self.exerciseID = exerciseID
        self.startTime = startTime
        self.exerciseCount = exerciseCount
        self.indexOfExercise = indexOfExercise
        self.totalProgress = totalProgress
        self.indexOfSet = indexOfSet
        self.setsProgress = setsProgress
        self.restStartTime = restStartTime
        self.restInterval = restInterval
    }
    
    // Implement the encode(to:) method to customize encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(liveActivityID, forKey: .liveActivityID)
        try container.encode(currentExercise?.id, forKey: .exerciseID)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(exerciseCount, forKey: .exerciseCount)
        try container.encode(indexOfExercise, forKey: .indexOfExercise)
        try container.encode(totalProgress, forKey: .totalProgress)
        try container.encode(indexOfSet, forKey: .indexOfSet)
        try container.encode(setsProgress, forKey: .setsProgress)
        try container.encode(restStartTime, forKey: .restStartTime)
        try container.encode(restInterval, forKey: .restInterval)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        liveActivityID = try container.decode(String.self, forKey: .liveActivityID)
        exerciseID = try container.decode(String.self, forKey: .exerciseID)
        startTime = try container.decode(Date.self, forKey: .startTime)
        exerciseCount = try container.decode(Int.self, forKey: .exerciseCount)
        indexOfExercise = try container.decode(Int.self, forKey: .indexOfExercise)
        totalProgress = try container.decode(Double.self, forKey: .totalProgress)
        indexOfSet = try container.decode(Int.self, forKey: .indexOfSet)
        setsProgress = try container.decode(Double.self, forKey: .setsProgress)
        restStartTime = try container.decode(Date.self, forKey: .restStartTime)
        restInterval = try container.decode(Double.self, forKey: .restInterval)
    }

    enum CodingKeys: String, CodingKey {
        case liveActivityID
        case exerciseID
        case startTime
        case exerciseCount
        case indexOfExercise
        case totalProgress
        case indexOfSet
        case setsProgress
        case restStartTime
        case restInterval
    }
}
