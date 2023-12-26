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
    @Published var selectedDate: Date
    @Published var currentPlan: Plan = .init(name: "", arrangedExercises: [], startDate: .init(), repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: false)
    
    @Published var createWeek: Bool = false
    @Published var weeks: [[Date.Weekday]] = []
    @Published var currentWeekIndex: Int = 1
    
    @Published var arrangedExercises: [ArrangedExercise] = []

    init(context: ModelContext, currentDate: Date = .init()) {
        self.context = context
        self.selectedDate = currentDate
        self.currentPlan = getPlan(by: currentDate)
        self.arrangedExercises = self.currentPlan.arrangedExercises.sorted { $0.order < $1.order }
    }
    
    func incrementOrderNumber() -> Int {
        guard currentPlan.arrangedExercises.isEmpty == false else {
            return 0
        }
        
        return currentPlan.arrangedExercises.count
    }
    
    func updateOrderNumbers() {
        for i in 0..<arrangedExercises.count {
            let exercise = arrangedExercises[i]
            exercise.order = i
        }
        
        currentPlan.arrangedExercises = arrangedExercises
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
    
    /// Get  plan by date
    func getPlan(by date: Date) -> Plan {
        if let plan = fetchPlan(by: date) {
            return plan
        }
        else {
            let plan = createNewPlan(by: date)
            return plan
        }
    }
    
    /// Create new plan
    func createNewPlan(by date: Date) -> Plan {
        let plan = Plan(name: "", arrangedExercises: [], startDate: date, repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: false)
        context.insert(plan)
        return plan
    }
    
    /// Get current plan by date
    func fetchPlan(by date: Date) -> Plan? {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedDate)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return nil }
        
        let fetchDescriptor = FetchDescriptor<Plan>(predicate: #Predicate<Plan> { $0.startDate >= startDate && $0.startDate <= endDate }, sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
        
        do {
            let plans = try context.fetch(fetchDescriptor)
            return plans.first
        }
        catch {
            print(error.localizedDescription)
            return nil
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
    
    func deleteExercise(exercise: ArrangedExercise) {
        if let index = arrangedExercises.firstIndex(where: { $0 == exercise }) {
            arrangedExercises.remove(at: index)
        }
        
        context.delete(exercise)
        updateOrderNumbers()
        reloadArrangedExercises()
    }
    
    func reloadArrangedExercises() {
        arrangedExercises = currentPlan.arrangedExercises.sorted { $0.order < $1.order }
    }
    
    /// Import exercises from plan
    func importExercises(from plan: Plan) {
        var newExercises: [ArrangedExercise] = []
        for exercise in plan.arrangedExercises {
            let newExercise = ArrangedExercise(exercise: exercise.exercise, 
                                               repetitions: exercise.repetitions,
                                               sets: exercise.repetitions,
                                               weight: exercise.weight,
                                               durationOfSet: exercise.durationOfSet,
                                               restIntevals: exercise.restIntevals,
                                               order: exercise.order,
                                               tags: exercise.tags,
                                               isCompleted: false)
            newExercises.append(newExercise)
        }
        currentPlan.arrangedExercises = newExercises
        reloadArrangedExercises()
    }
}


