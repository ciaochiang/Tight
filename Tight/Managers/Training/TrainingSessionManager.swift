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
    private let healthStore = HKHealthStore()
    @EnvironmentObject var logger: CustomLogger
    @Environment(\.modelContext) private var context
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
    
    override init() {
        super.init()
        
        /// Create state observer
        $content.sink { [weak self] newValue in
            /// Change is running or not
            DispatchQueue.main.async {
                self?.isRunning = newValue.state != .notStarted
            }
        }
        .store(in: &cancellables)
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
        createLiveAcitvity()
        
        /// Update `Watch`
        onUpdateWatch()
    }
    
    func endSession() {
        /// Cancel all scheduled notification
        cancelScheduledNotifications()
        
        /// Dismiss Live Activity
        dismissLiveActivity()
        
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
        currentRestTimeFrame?.endTime = currentTime
        if let restTimeFrame = currentRestTimeFrame {
            plan?.trainingLog?.restTimeFrames.append(restTimeFrame)
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
        guard let exercise = arrangedExercises.first(where: { $0.id.uuidString == exerciseID }) else { return }
        
        /// 2.
        /// - Go rest
        /// - If there is more set of current exercise, then update the IndexOfSet number
        /// - If there is no more set, then mark it as completed and  jump to next exercise
        /// - If there is no next exercise, then complete the training session
        if content.indexOfSet >= Int(exercise.sets - 1) {
            /// Sets are completed, mark exercise as completed and jump to next exercise
            exercise.isCompleted = true
            
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
        /// Update end time
        let currentTime = Date.now
        plan?.trainingLog?.endTime = currentTime
        
        /// Update current progress to completed
        let progress: Double = 1.0
        DispatchQueue.main.async {
            self.content.setsProgress = progress
            self.content.totalProgress = progress
            
            /// Update `Live Activity`
            self.onUpdateLiveActivity()
            
            /// Update `Watch`
            self.onUpdateWatch()
        }
        
        /// Stop and Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.endSession()
        }
    }
    
    /// Skip Rest
    func endRest() {        
        /// Process task for rest time end
        if let plan = plan, let restTimeFrame = currentRestTimeFrame {
            onRestTimeEnd(currentTime: Date.now, plan: plan, restTimeFrame: restTimeFrame)
        }
        
        DispatchQueue.main.async {
            self.content.restStartTime = nil
            self.content.restInterval = 0
            self.content.state = .training
            
            /// Update live activity
            self.onUpdateLiveActivity()
            
            /// Update Watch
            self.onUpdateWatch()
        }
    }
    
    /// Next Set
    func nextSet() {
        let currentTime = Date.now
        
        /// New values
        let newIndexOfSet = content.indexOfSet + 1
        let newRestInterval = content.currentExerciseRestInterval()
        
        /// Process task for rest time start
        currentRestTimeFrame = onRestTimeStart(currentTime: currentTime, restTimeInterval: newRestInterval)
        
        DispatchQueue.main.async {
            self.content.state = .resting
            self.content.setIndexOfSet(index: newIndexOfSet)
            self.content.restStartTime = currentTime
            self.content.restInterval = newRestInterval
            
            /// Update Live Activity
            self.onUpdateLiveActivity()
            
            /// Update Watch
            self.onUpdateWatch()
        }
    }
    
    /// Next Exericse
    func nextExercise() {
        /// Complete current exercise and update progress to 100%
        onCurrentExerciseCompleted()
        
        /// Change state to `resting`
        let newState: TTSessionState = .resting
        let currentTime = Date.now
        
        /// New  exercise
        let newIndexOfExercise = content.indexOfExercise + 1
        let newExercise = arrangedExercises[newIndexOfExercise]
        newExercise.startTime = currentTime
        
        /// Create new rest time frame and set `startTime`
        let newRestInterval = newExercise.restIntevals
        
        /// Create new rest time frame and set `startTime`
        currentRestTimeFrame = onRestTimeStart(currentTime: currentTime, restTimeInterval: newRestInterval)
        
        /// Wait for `0.7` secs and shift to next exercise
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.content.state = newState
            self.content.setCurrentExercise(newExercise)
            self.content.setIndexOfExercise(index: newIndexOfExercise)
            self.content.setIndexOfSet(index: 0)
            self.content.restStartTime = currentTime
            self.content.restInterval = newExercise.restIntevals
            
            /// Update Live Activity
            self.onUpdateLiveActivity()
            
            /// Send message to Watch
            self.onUpdateWatch()
        }
    }
}

// MARK: Helper
extension TrainingSessionManager {
    func calculateProgress(index: Int, totalCount: Int) -> Double {
        return Double(index) / Double(totalCount - 1)
    }
    
    func onCurrentExerciseCompleted() {
        /// Update `endTime` for current exercise
        let currentTime = Date.now
        content.currentExercise?.endTime = currentTime
        
        /// Update `progress`
        let newSetsProgress = 1.0
        DispatchQueue.main.async {
            self.content.setsProgress = newSetsProgress
            
            /// Update `Live Activity`
            self.onUpdateLiveActivity()
            
            /// Update `Watch`
            self.onUpdateWatch()
        }
    }
}
