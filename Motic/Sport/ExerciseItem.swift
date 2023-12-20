//
//  ExerciseItem.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/19.
//

import Foundation

struct ExercisePlan: Identifiable {
    var id: Int
    var scheduledDate: Date
    var exerciseItems: [ExerciseItem]
    var repeats: [Int]
    var until: Date
    var intervalOfSet: TimeInterval
    var totalDuration: TimeInterval
}

struct ScheduledExerciseItem: Identifiable {
    var id: Int
    var exerciseItem: ExerciseItem
    var reps: Int
    var sets: Int
    var intensity: Double
    var intensityUnit: WeightUnit
    var isCompleted: Bool
}

struct ExerciseItem: Identifiable, Hashable {
    var id: Int
    var name: String
    var description: String
    var reps: Int
    var sets: Int
    var intensity: Double
}

struct ExerciseTag: Identifiable {
    var id: Int
    var name: String
}

enum WeightUnit {
    case pound
    case kilogram
}


enum Exercise: Int {
    // Chest
    case chessPress = 0
    case chestFly = 1
    case benchPress = 2
}
