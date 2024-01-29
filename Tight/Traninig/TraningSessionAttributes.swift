//
//  TraningSessionAttributes.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/29.
//

import Foundation

enum TraningSessionAttributes {
    case action
    case state
    case currentExerciseID
    case exerciseName
    case startTime
    case restStartTime
    case restInterval
    case weight
    case weightUnit
    case repetitions
    case indexOfSet
    case setsProgress
    case totalProgress
    
    var name: String {
        return String(describing: self)
    }
}
