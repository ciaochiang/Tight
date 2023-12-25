//
//  ArrangedExercise.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import Foundation
import SwiftData

@Model
class ArrangedExercise: Identifiable {
    var exercise: Exercise
    var repetitions: Double
    var sets: Double
    var weight: Double
    var durationOfSet: TimeInterval
    var restIntevals: TimeInterval
    var order: Int
    var tags: [String]
    var isCompleted: Bool
    
    init(exercise: Exercise, 
         repetitions: Double,
         sets: Double,
         weight: Double,
         durationOfSet: TimeInterval,
         restIntevals: TimeInterval,
         order: Int,
         tags: [String],
         isCompleted: Bool) {
        self.exercise = exercise
        self.repetitions = repetitions
        self.sets = sets
        self.weight = weight
        self.durationOfSet = durationOfSet
        self.restIntevals = restIntevals
        self.order = order
        self.tags = tags
        self.isCompleted = isCompleted
    }
}
