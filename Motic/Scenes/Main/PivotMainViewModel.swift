//
//  PivotMainViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import Foundation
import SwiftUI
import SwiftData

class PivotMainViewModel: ObservableObject {
    @Published var selectedDate: Date = .init()
    @Published var scheduledExercises: [ScheduledExercise] = []
}

@Model
class ScheduledExercise: Identifiable {
    var exericse: Exercise
    var scheduledDate: Date
    var repetitions: Double
    var sets: Double
    var restIntevals: TimeInterval
    var isCompleted: Bool
    
    init(exericse: Exercise, scheduledDate: Date, repetitions: Double, sets: Double, restIntevals: TimeInterval, isCompleted: Bool) {
        self.exericse = exericse
        self.scheduledDate = scheduledDate
        self.repetitions = repetitions
        self.sets = sets
        self.restIntevals = restIntevals
        self.isCompleted = isCompleted
    }
}



