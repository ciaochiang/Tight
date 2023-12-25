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
    var context: ModelContext
    @Published var selectedDate: Date = .init()
    @Published var scheduledExercises: [ScheduledExercise] = []
    
    @Published var createWeek: Bool = false
    @Published var weeks: [[Date.Weekday]] = []
    @Published var currentWeekIndex: Int = 1

    init(context: ModelContext) {
        self.context = context
    }
    
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
    
    /// Load Weeks
    func loadWeeks() {
        let currentWeek = Date().fetchWeek()
        
        if let firstDate = currentWeek.first?.date {
            weeks.append(firstDate.createPreviousWeek())
        }
        
        weeks.append(currentWeek)
        
        if let lastDate = currentWeek.last?.date {
            weeks.append(lastDate.createNextWeek())
        }
    }
    
    /// Load Scheduled Exercises
    func loadScheduledExercises(selectedDate: Date) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedDate)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return }
        
        let fetchDescriptor = FetchDescriptor<ScheduledExercise>(predicate: #Predicate<ScheduledExercise> { $0.scheduledDate >= startDate && $0.scheduledDate <= endDate }, sortBy: [SortDescriptor(\.order)])
        
        do {
            scheduledExercises = try context.fetch(fetchDescriptor)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func paginateWeek() {
        if weeks.indices.contains(currentWeekIndex) {
            if let firstDate = weeks[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                /// Inserting new week at 0th indx and removing last array item
                weeks.insert(firstDate.createPreviousWeek(), at: 0)
                weeks.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastDate = weeks[currentWeekIndex].last?.date, currentWeekIndex == (weeks.count - 1) {
                /// Inserting new week at last indx and removing last array item
                weeks.append(lastDate.createNextWeek())
                weeks.removeFirst()
                currentWeekIndex = weeks.count - 2
            }
        }
    }
    
    func deleteExercise(exercise: ScheduledExercise) {
        context.delete(exercise)
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



