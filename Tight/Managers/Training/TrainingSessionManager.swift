//
//  TrainingSessionManager.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/3.
//

import Foundation
import SwiftUI
import ActivityKit
import HealthKit
import Combine
import SwiftData

/**
 - Countdown timer
 - Based on  Arranged Exercises rest intervals
 -
 */
class TrainingSessionManager: NSObject, ObservableObject {
    @EnvironmentObject var logger: CustomLogger
    var context: ModelContext?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Common Properties
    private(set) var plan: Plan?
    private(set) var arrangedExercises: [ArrangedExercise] = []
    private var currentRestTimeFrame: RestTimeFrame?
    
    @Published var isRunning: Bool = false
    @Published var content = TrainingSessionContent()
    
    /// Live Activity Content State
    @Published var contentState: LiveActivityAttributes.ContentState?
    
    private var cancellables = Set<AnyCancellable>()
    
    let operationQueue = OperationQueue()
    
    override init() {
        super.init()
        /// Limit queue only can process 1 task at a time
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        operationQueue.cancelAllOperations()
        
        /// Create state observer
        $content.sink { [weak self] newValue in
            /// Change is running or not
            DispatchQueue.main.async {
                self?.isRunning = newValue.state != .notStarted
            }
        }
        .store(in: &cancellables)
    }
    
    func configure(modelContext: ModelContext) {
        self.context = modelContext
    }
    
    func startSession(plan: Plan?, arrangedExercises: [ArrangedExercise]) {
        /// Ensure arranged exercise list is not empty
        guard arrangedExercises.isEmpty == false else { return }
        
        let clonedArrangedExercise = arrangedExercises.sorted(by: { $0.order < $1.order })
        
        let currentTime = Date.now
        self.plan = plan
        self.arrangedExercises = clonedArrangedExercise
        self.content.exerciseCount = clonedArrangedExercise.count
        
        /// Update state  start time and change state
        content.state = .training
        content.startTime = currentTime
        
        /// Get first exercise and update start time
        let firstExercise = clonedArrangedExercise[content.indexOfExercise]
        firstExercise.startTime = currentTime
        content.setCurrentExercise(firstExercise)
        
        /// Create training log
        createTrainingLog()
        
        /// Add live activity
        createLiveAcitvity(startTime: currentTime, exercise: firstExercise)
        
        /// Update `Watch`
        onUpdateWatch()
    }
    
    func endSession() {
        /// Cancel all scheduled notification
        cancelScheduledNotifications()
        
        /// Dismiss Live Activity
        dismissLiveActivity()
        
        /// Cancel all operations
        operationQueue.cancelAllOperations()
        
        /// Send end message to Watch
        let state: TTSessionState = .notStarted
        TTWCSession.shared.sendMessage([.action: "end", .state: state.rawValue])
        
        /// Update end time to training log
        if let trainingLog = plan?.trainingLog {
            let currentTime = Date.now
            trainingLog.endTime = currentTime
        }
        
        /// Reset Properties
        DispatchQueue.main.async {
            self.content = TrainingSessionContent()
        }
    }
    
    func handleTimerAction() {
        /// Verify the date is over rest end time
        guard let restStartTime = content.restStartTime else { return }
        
        /// Determine rest time is over or not
        guard Date.now >= restStartTime.addingTimeInterval(content.restInterval) else { return }
        
        // Haptic Feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let currentTime = Date.now
        let newState: TTSessionState = .training
        
        /// Set `endTime` to current rest time frame and save to `trainingLog`
        if let restTimeFrame = currentRestTimeFrame, let trainingLog = plan?.trainingLog {
            restTimeFrame.endTime = currentTime
            trainingLog.restTimeFrames?.append(restTimeFrame)
        }
        
        /// Reset rest time
        DispatchQueue.main.async {
            self.content.state = newState
            self.content.restStartTime = nil
            self.content.restInterval = 0
            
            /// Update `Live Activity`
            self.onUpdateLiveActivity()
            
            /// Update `Watch`
            self.onUpdateWatch()
        }
    }
    
    func completeCurrentSet(exerciseID: String) {
        /// 1. Find the corresponding exercise
        guard let exercise = fetchArrangedExercise(by: exerciseID) else { return }
        
        /// 2.
        /// - Go rest
        /// - If there is more set of current exercise, then update the IndexOfSet number
        /// - If there is no more set, then mark it as completed and  jump to next exercise
        /// - If there is no next exercise, then complete the training session
        if content.indexOfSet >= Int(exercise.sets - 1) {
            /// Complete current exercise and update progress to 100%
            onCurrentExerciseCompleted(exercise: exercise)
            
            /// If there is more exercise, then `nextExercise`, else  `completeTrainingSession`
            if content.indexOfExercise + 1 >= arrangedExercises.count {
                /// Complete training session
                done()
            }
            else {
                nextExercise()
            }
        }
        else {
            /// Keep current exercise and go to next set
            nextSet()
        }
    }

    /// Done
    func done() {
        let progress: Double = 1.0
        let currentTime = Date.now
        
        var newContent = content
        newContent.setsProgress = progress
        newContent.totalProgress = progress
        
        /// Update `Watch`
        onUpdateWatch(content: newContent)
        
        /// Update current progress to completed
        operationQueue.addOperation {
            DispatchQueue.main.async {
                self.content.setsProgress = progress
                self.content.totalProgress = progress
                self.plan?.trainingLog?.endTime = currentTime

                /// Update `Live Activity`
                self.onUpdateLiveActivity()
            }
        }

        /// Stop and Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.endSession()
        }
    }
    
    /// Skip Rest
    func endRest() {        
        /// Process task for rest time end
        if let plan = plan, let restTimeFrame = currentRestTimeFrame {
            onRestTimeEnd(currentTime: Date.now, plan: plan, restTimeFrame: restTimeFrame)
        }
        
        var newContent = content
        newContent.restStartTime = nil
        newContent.restInterval = 0
        newContent.state = .resting
        
        /// Update Watch
        onUpdateWatch(content: newContent)
        
        operationQueue.addOperation {
            DispatchQueue.main.async {
                self.content.restStartTime = nil
                self.content.restInterval = 0
                self.content.state = .training
                
                /// Update live activity
                self.onUpdateLiveActivity()
            }
        }
    }
    
    /// Next Set
    func nextSet() {
        let currentTime = Date.now
        
        var newContent = content
        
        /// New values
        let newIndexOfSet = content.indexOfSet + 1
        let newRestInterval = content.currentExerciseRestInterval()
        newContent.state = .resting
        newContent.indexOfSet = newIndexOfSet
        newContent.restStartTime = currentTime
        newContent.restInterval = content.currentExerciseRestInterval()
        
        /// Update Watch
        onUpdateWatch(content: newContent)
        
        /// Process task for rest time start
        currentRestTimeFrame = onRestTimeStart(currentTime: currentTime, restTimeInterval: newRestInterval)
        
        operationQueue.addOperation {
            DispatchQueue.main.async {
                self.content.state = .resting
                self.content.setIndexOfSet(index: newIndexOfSet)
                self.content.restStartTime = currentTime
                self.content.restInterval = newRestInterval
                
                /// Update Live Activity
                self.onUpdateLiveActivity()
            }
        }
    }
    
    /// Next Exericse
    func nextExercise() {
        /// Change state to `resting`
        let newState: TTSessionState = .resting
        let currentTime = Date.now
        
        /// New  exercise
        let newIndexOfExercise = content.indexOfExercise + 1
        let newExercise = arrangedExercises[newIndexOfExercise]
        newExercise.startTime = currentTime
        
        /// Create new rest time frame and set `startTime`
        let newRestInterval = newExercise.restIntevals.isNaN ? 0 : newExercise.restIntevals
        
        var newContent = content
        newContent.state = .resting
        newContent.restStartTime = currentTime
        newContent.restInterval = newRestInterval
        newContent.setCurrentExercise(newExercise)
        newContent.setIndexOfSet(index: 0)
        newContent.setIndexOfExercise(index: newIndexOfExercise)
        
        /// Send message to Watch
        onUpdateWatch(content: newContent)
        
        /// Create new rest time frame and set `startTime`
        currentRestTimeFrame = onRestTimeStart(currentTime: currentTime, restTimeInterval: newRestInterval)
        
        /// Wait for `0.3` secs and shift to next exercise
        operationQueue.addOperation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.content.state = newState
                self.content.setCurrentExercise(newExercise)
                self.content.setIndexOfExercise(index: newIndexOfExercise)
                self.content.setIndexOfSet(index: 0)
                self.content.restStartTime = currentTime
                self.content.restInterval = newExercise.restIntevals
                
                /// Update Live Activity
                self.onUpdateLiveActivity()
            }
        }
    }
}

// MARK: Swift Data
extension TrainingSessionManager {
    func fetchArrangedExercise(by exerciseID: String) -> ArrangedExercise? {
        if let uuid = UUID(uuidString: exerciseID), let exercise = arrangedExercises.first(where: { $0.id == uuid }) {
            return exercise
        }
        
        guard let uuid = UUID(uuidString: exerciseID) else { return nil }
        
        let fetchDescriptor = FetchDescriptor<ArrangedExercise>(predicate: #Predicate<ArrangedExercise> { exercise in
            return exercise.id == uuid
        })
        
        do {
            let exercises = try context?.fetch(fetchDescriptor)
            return exercises?.first
        }
        catch {
            logger.log(error.localizedDescription, level: .error)
            return nil
        }
    }
}

// MARK: Helper
extension TrainingSessionManager {
    func calculateProgress(index: Int, totalCount: Int) -> Double {
        return Double(index) / Double(totalCount - 1)
    }
    
    func onCurrentExerciseCompleted(exercise: ArrangedExercise) {
        let newSetsProgress = 1.0
        let currentTime = Date.now
        
        /// Update `Watch`
        var newContent = content
        newContent.setsProgress = newSetsProgress
        onUpdateWatch(content: newContent)
        
        operationQueue.addOperation {
            DispatchQueue.main.async {
                /// Sets are completed, mark exercise as completed and jump to next exercise
                exercise.isCompleted = true
            
                self.content.setsProgress = newSetsProgress
                self.content.currentExercise?.endTime = currentTime
                
                /// Update `Live Activity`
                self.onUpdateLiveActivity()
            }
        }
    }
}
