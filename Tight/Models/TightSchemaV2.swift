//
//  TightSchemaV2.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/29.
//

import Foundation
import SwiftData

enum TightSchemaV2: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Plan.self, ArrangedExercise.self, Tag.self]
    }
    
    static var versionIdentifier: Schema.Version = .init(1, 1, 0)
}

extension TightSchemaV2 {
    @Model
    class Plan {
        @Attribute(.unique) var id: UUID
        var name: String
        
        @Relationship(deleteRule: .cascade)
        var arrangedExercises = [ArrangedExercise]()
        
        var startDate: Date
        var endDate: Date?
        var repeats: [Int]
        var duration: TimeInterval
        var updatedDate: Date
        var createdDate: Date
        var tags: [String]
        var isPreset: Bool
        
        init(id: UUID = UUID(),
             name: String,
             startDate: Date,
             endDate: Date? = nil,
             repeats: [Int],
             duration: Double,
             updatedDate: Date,
             createdDate: Date,
             tags: [String],
             isPreset: Bool) {
            self.id = id
            self.name = name
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
    
    @Model
    class ArrangedExercise {
        @Attribute(.unique) var id: UUID
        var exercise: Exercise
        var repetitions: Double
        var sets: Double
        var weight: Double
        var weightUnit: Int = 0
        var durationOfSet: TimeInterval
        var restIntevals: TimeInterval
        var order: Int
        var tags: [Int]
        var isCompleted: Bool
        
        init(id: UUID = UUID(),
             exercise: Exercise,
             repetitions: Double,
             sets: Double,
             weight: Double,
             weightUnit: Int = 0,
             durationOfSet: TimeInterval,
             restIntevals: TimeInterval,
             order: Int,
             tags: [Int],
             isCompleted: Bool) {
            self.id = id
            self.exercise = exercise
            self.repetitions = repetitions
            self.sets = sets
            self.weight = weight
            self.weightUnit = weightUnit
            self.durationOfSet = durationOfSet
            self.restIntevals = restIntevals
            self.order = order
            self.tags = tags
            self.isCompleted = isCompleted
        }
    }

    @Model
    class Tag {
        @Attribute(.unique) var id: UUID
        var name: String
        var colourR: Double
        var colourG: Double
        var colourB: Double
        var colourA: Double
        var isInitial: Bool
        
        init(id: UUID = UUID(),
             name: String,
             colourR: Double,
             colourG: Double,
             colourB: Double,
             colourA: Double,
             isInitial: Bool = false) {
            self.id = id
            self.name = name
            self.colourR = colourR
            self.colourG = colourG
            self.colourB = colourB
            self.colourA = colourA
            self.isInitial = isInitial
        }
    }
}
