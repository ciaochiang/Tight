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
    private var context: ModelContext
    private var logger: CustomLogger
    @Published var selectedDate: Date
    @Published var currentPlan: Plan
    @Published var createWeek: Bool = false
    @Published var weeks: [[Date.Weekday]] = []
    @Published var plansOfWeeks: [Plan] = []
    @Published var currentWeekIndex: Int = 1
    @Published var showDailySummary: Bool = false
    
    init(context: ModelContext, logger: CustomLogger, currentDate: Date) {
        self.context = context
        self.logger = logger
        self.selectedDate = currentDate
        self.currentPlan = PivotMainViewModel.getPlan(context: context, by: currentDate)
        determineDailySummaryVisibility()
    }
    
    func determineDailySummaryVisibility() {
        showDailySummary = currentPlan.trainingLog != nil || currentPlan.arrangedExercises.contains(where: { $0.isCompleted })
    }
}

// MARK: Plan
extension PivotMainViewModel {
    /// Get  plan by date
    static func getPlan(context: ModelContext, by date: Date) -> Plan {
        if let plan = PivotMainViewModel.fetchPlan(context: context, by: date) {
            return plan
        }
        else {
            let plan = PivotMainViewModel.createNewPlan(context: context, by: date)
            return plan
        }
    }
    
    /// Create new plan
    static func createNewPlan(context: ModelContext, by date: Date) -> Plan {
        let plan = Plan(name: "", startDate: date, repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: false)
        context.insert(plan)
        return plan
    }
    
    /// Get current plan by date
    static func fetchPlan(context: ModelContext,by date: Date) -> Plan? {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return nil }
        
        let fetchDescriptor = FetchDescriptor<Plan>(predicate: #Predicate<Plan> {
            $0.startDate >= startDate && $0.startDate < endDate && $0.isPreset == false
        }, sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
        
        do {
            let plans = try context.fetch(fetchDescriptor)
            return plans.first
        }
        catch {
            let logger = CustomLogger()
            logger.log(error.localizedDescription, level: .error)
            return nil
        }
    }
    
    /// Load Plans of Weeks
    func loadPlans(weeks: [[Date.Weekday]]) {
        let dates = weeks.flatMap { $0.map { $0.date } }.sorted { $0 < $1 }
        if let startDate = dates.first, let endDate = dates.last {
            let plans = fetchPlans(context: context, startDate: startDate, endDate: endDate)
            plansOfWeeks = plans
        }
    }
    
    func fetchPlans(context: ModelContext, startDate: Date, endDate: Date) -> [Plan] {
        let fetchDescriptor = FetchDescriptor<Plan>(predicate: #Predicate<Plan> {
            $0.startDate >= startDate && $0.startDate <= endDate && $0.isPreset == false
        }, sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
        
        do {
            return try context.fetch(fetchDescriptor)
        }
        catch {
            let logger = CustomLogger()
            logger.log(error.localizedDescription, level: .error)
            return []
        }
    }
}

// MARK: Calendar
extension PivotMainViewModel {
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
    
    func onSelectedDate(_ date: Date) {
        selectedDate = date
        currentPlan = PivotMainViewModel.getPlan(context: context, by: date)
        determineDailySummaryVisibility()
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
}

// MARK: Exercise
extension PivotMainViewModel {
    func deleteExercise(exercise: ArrangedExercise) {
        if let index = currentPlan.arrangedExercises.firstIndex(where: { $0 == exercise }) {
            currentPlan.arrangedExercises.remove(at: index)
            context.delete(exercise)
        }
        
        // Update the order numbers of all exercises in the updated array
        for (index, exercise) in currentPlan.arrangedExercises.sorted(by: { $0.order < $1.order }).enumerated() {
            exercise.order = index
        }
    }
    
    /// Import exercises from plan
    func importExercises(from plan: Plan) {
        var newExercises: [ArrangedExercise] = []
        for exercise in plan.arrangedExercises {
            let newExercise = ArrangedExercise(exercise: exercise.exercise,
                                               repetitions: exercise.repetitions,
                                               sets: exercise.sets,
                                               weight: exercise.weight,
                                               durationOfSet: exercise.durationOfSet,
                                               restIntevals: exercise.restIntevals,
                                               order: exercise.order,
                                               tags: exercise.tags,
                                               isCompleted: false)
            newExercises.append(newExercise)
        }
        
        currentPlan.arrangedExercises = newExercises.sorted(by: { $0.order < $1.order })
        try? context.save()
    }
}

// MARK: - Sorting
extension PivotMainViewModel {
    func incrementOrderNumber() -> Int {
        return currentPlan.arrangedExercises.count
    }
    
    func updateOrderNumbers(from indexSet: IndexSet, to offset: Int) {
        guard let itemIndex = indexSet.first else { return }
            
        var exercises = currentPlan.arrangedExercises.sorted(by: { $0.order < $1.order })
                
        // Ensure that the provided offset is within a valid range
        if offset < 0 || offset > exercises.count {
            return
        }
        
        // Remove the moved item from the exercises array
        let movedExercise = exercises.remove(at: itemIndex)
        
        // Insert the moved item at the new position (offset)
        
        if offset > itemIndex  {
            exercises.insert(movedExercise, at: offset - 1)
        } else {
            exercises.insert(movedExercise, at: offset)
        }
        
        // Update the order numbers of all exercises in the updated array
        for (index, exercise) in exercises.enumerated() {
            exercise.order = index
        }
        
        // Assign the updated exercises array back to your currentPlan
        currentPlan.arrangedExercises = exercises
    }
}


