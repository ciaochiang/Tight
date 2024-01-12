//
//  TightSchemaV1.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/29.
//

import Foundation
import SwiftData

// MARK: Swift Data Models
typealias Plan = TightSchemaV1.Plan
typealias ArrangedExercise = TightSchemaV1.ArrangedExercise
typealias Tag = TightSchemaV1.Tag

enum TightSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Plan.self, ArrangedExercise.self, Tag.self]
    }
    
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
}

extension TightSchemaV1 {
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
        
        @Relationship(deleteRule: .cascade)
        var trainingLog: TrainingLog?
        
        init(id: UUID = UUID(),
             name: String,
             startDate: Date,
             endDate: Date? = nil,
             repeats: [Int],
             duration: Double,
             updatedDate: Date,
             createdDate: Date,
             tags: [String],
             isPreset: Bool,
             trainingLog: TrainingLog? = nil) {
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
            self.trainingLog = trainingLog
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
        var startTime: Date?
        var endTime: Date?
        
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
             isCompleted: Bool, 
             startTime: Date? = nil,
             endTime: Date? = nil) {
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
            self.startTime = startTime
            self.endTime = endTime
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
    
    @Model
    class TrainingLog {
        @Attribute(.unique) var id: UUID
        var startTime: Date?
        var endTime: Date?
        
        init(id: UUID, 
             startTime: Date? = nil,
             endTime: Date? = nil) {
            self.id = id
            self.startTime = startTime
            self.endTime = endTime
        }
    }
}
