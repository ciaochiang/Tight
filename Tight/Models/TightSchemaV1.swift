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
typealias TrainingLog = TightSchemaV1.TrainingLog
typealias RestTimeFrame = TightSchemaV1.RestTimeFrame

enum TightSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Plan.self, ArrangedExercise.self, Set.self, Tag.self, TrainingLog.self, RestTimeFrame.self]
    }
    
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
}

extension TightSchemaV1 {
    @Model
    class Plan {
        var id: UUID = UUID()
        var name: String = ""
        
        @Relationship(deleteRule: .cascade, inverse: \ArrangedExercise.plan)
        var arrangedExercises: [ArrangedExercise]?
        
        var startDate: Date = Date.now
        var endDate: Date?
        var repeats: [Int] = []
        var duration: TimeInterval = 0
        var updatedDate: Date = Date.now
        var createdDate: Date = Date.now
        var tags: [String] = []
        var isPreset: Bool = false
        
        @Relationship(deleteRule: .cascade, inverse: \TrainingLog.plan)
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
        
        func alleExercises() -> [ArrangedExercise] {
            return arrangedExercises?.sorted(by: { $0.order < $1.order }) ?? []
        }
    }
    
    @Model
    class ArrangedExercise {
        var id: UUID = UUID()
        var exercise: Exercise = Exercise.none
        var repetitions: Double = 0
        
        /// Deprecated
        var sets: Double = 0
        
        @Relationship(deleteRule: .cascade, inverse: \Set.arrangedExercise)
        var customSets: [Set]?
        
        var weight: Double = 0
        var weightUnit: Int = 0
        var durationOfSet: TimeInterval = 0
        var restIntevals: TimeInterval = 0
        var order: Int = 0
        var tags: [Int] = []
        var isCompleted: Bool = false
        var startTime: Date?
        var endTime: Date?
        
        /// Inverse
        var plan: Plan?
        
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
    class Set {
        var id: UUID = UUID()
        var weight: Double = 0
        var weightUnit: Int = 0
        var repetitions: Double = 0
        var isCompleted: Bool = false
        var startTime: Date?
        var endTime: Date?
        var createdTime: Date = Date.now
        
        /// Inverse
        var arrangedExercise: ArrangedExercise?
        
        init(id: UUID = UUID(),
             weight: Double,
             weightUnit: Int,
             repetitions: Double,
             isCompleted: Bool,
             startTime: Date? = nil,
             endTime: Date? = nil, 
             createdTime: Date = .now) {
            self.id = id
            self.weight = weight
            self.weightUnit = weightUnit
            self.repetitions = repetitions
            self.isCompleted = isCompleted
            self.startTime = startTime
            self.endTime = endTime
            self.createdTime = createdTime
        }
    }

    @Model
    class Tag {
        var id: UUID = UUID()
        var name: String = ""
        var colourR: Double = 0
        var colourG: Double = 0
        var colourB: Double = 0
        var colourA: Double = 0
        var isInitial: Bool = false
        
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
        var id: UUID = UUID()
        var startTime: Date?
        var endTime: Date?
        
        /// Inverse
        var plan: Plan?
        
        @Relationship(deleteRule: .cascade, inverse: \RestTimeFrame.trainingLog)
        var restTimeFrames: [RestTimeFrame]?
        
        init(id: UUID = UUID(),
             startTime: Date? = nil,
             endTime: Date? = nil) {
            self.id = id
            self.startTime = startTime
            self.endTime = endTime
        }
    }
    
    @Model
    class RestTimeFrame {
        var id: UUID = UUID()
        var startTime: Date?
        var endTime: Date?
        
        /// Inverse
        var trainingLog: TrainingLog?
        
        init(id: UUID = UUID(),
             startTime: Date? = nil,
             endTime: Date? = nil) {
            self.id = id
            self.startTime = startTime
            self.endTime = endTime
        }
    }
}
