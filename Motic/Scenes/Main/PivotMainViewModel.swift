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
    
    func incrementOrderNumber() -> Int {
        guard scheduledExercises.isEmpty == false else {
            return 0
        }
        
        return scheduledExercises.count
    }
    
    func updateOrderNumbers() {
        for i in 0..<scheduledExercises.count {
            let exercise = scheduledExercises[i]
            exercise.order = i
        }
    }
}

@Model
class ScheduledExercise: Identifiable {
    var exericse: Exercise
    var scheduledDate: Date
    var repetitions: Double
    var sets: Double
    var restIntevals: TimeInterval
    var isCompleted: Bool
    var order: Int
    
    init(exericse: Exercise, scheduledDate: Date, repetitions: Double, sets: Double, restIntevals: TimeInterval, isCompleted: Bool, order: Int) {
        self.exericse = exericse
        self.scheduledDate = scheduledDate
        self.repetitions = repetitions
        self.sets = sets
        self.restIntevals = restIntevals
        self.isCompleted = isCompleted
        self.order = order
    }
}



