//
//  Plan.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import Foundation
import SwiftData

@Model
class Plan {
    var name: String
    var arrangedExercises: [ArrangedExercise]
    var startDate: Date
    var endDate: Date?
    var repeats: [Int]
    var duration: TimeInterval
    var updatedDate: Date
    var createdDate: Date
    var tags: [String]
    var isPreset: Bool
    
    init(name: String, 
         arrangedExercises: [ArrangedExercise],
         startDate: Date,
         endDate: Date? = nil,
         repeats: [Int],
         duration: TimeInterval,
         updatedDate: Date,
         createdDate: Date,
         tags: [String],
         isPreset: Bool) {
        self.name = name
        self.arrangedExercises = arrangedExercises
        self.startDate = startDate
        self.endDate = endDate
        self.repeats = repeats
        self.duration = duration
        self.updatedDate = updatedDate
        self.createdDate = createdDate
        self.tags = tags
        self.isPreset = isPreset
    }
}
