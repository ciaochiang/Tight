//
//  TrainingSessionManager.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/3.
//

import Foundation
import SwiftUI
import ActivityKit
import BackgroundTasks

/**
 - Countdown timer
 - Based on  Arranged Exercises rest intervals
 -
 */

class TrainingSessionManager: ObservableObject {
    private(set) var arrangedExercises: [ArrangedExercise] = []
    
    /// Live Activity Properties
    @Published var currentLiveActivityID: String = ""
    @Published var currentExercise: ArrangedExercise?
    @Published var totalExerciseCount: Int = 0
    @Published var currentStage: Int = 0
    @Published var currentIndexOfSet: Int = 1
    @Published var currentSetsProgress: Double = 0.0
    @Published var startTime: Date?
    @Published var restStartTime: Date?
    @Published var restIntervals: Double?
    @Published var isEnd: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    static let shared = TrainingSessionManager()
    
    /// Configure arranged exercises
    /// NOTE:  Invoke this function before start the training session
    func configure(arrangedExercises: [ArrangedExercise]) {
        /// End and remove existing live activtiy   
        
        self.arrangedExercises = arrangedExercises
        self.totalExerciseCount = arrangedExercises.count
        
        reset()
    }
    
    /// Start Training Session
    func startTrainingSession() {
        /// Ensure arranged exercise list is not empty
        guard arrangedExercises.isEmpty == false else { return }
        
        /// Remove existing activity
        removeExistingAcitvity()
        
        /// Init start time
        startTime = Date.now
        
        /// Add live activity
        addLiveAcitvity()
    }
    
    /// Stop Training Session
    func stopTrainingSession() {
        /// Reset
        reset()
        
        /// Remove live activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.completionType = 0
                await activity.update(.init(state: contentState, staleDate: nil))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.removeActivity()
                }
            }
        }
    }
    
    /// Handle function when timer tiggered it
    func handleTimerAction() {
        /// Verify the date is over rest end time
        guard let restStartTime = restStartTime, let restInterval = restIntervals else { return }
        
        /// Determine rest time is over or not
        guard Date.now >= restStartTime.addingTimeInterval(restInterval) else { return }
        
        /// Reset rest time
        DispatchQueue.main.async {
            self.restStartTime = nil
            self.restIntervals = nil
        }
        
        ///  Update activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.restStartTime = nil
                contentState.restIntervals = nil

                /// If rest time up, then alerting, if not, then just normal update
                let alertConfig = AlertConfiguration(
                    title: "Break Time is Over!",
                    body: "Let's go for next set",
                    sound: .default
                )
                
                /// Vibrate
                await UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                await activity.update(.init(state: contentState, staleDate: nil), alertConfiguration: alertConfig)
            }
        }
    }
    
    /// Complete current exercise
    func completeCurrentSet(exerciseID: String) {
        /// 1. Find the corresponding exercise
        guard let exercise = arrangedExercises.first(where: { $0.id.uuidString == exerciseID }) else { return }
        
        /// 2.
        /// - Go rest
        /// - If there is more set of current exercise, then update the IndexOfSet number
        /// - If there is no more set, then mark it as completed and  jump to next exercise
        /// - If there is no next exercise, then complete the training session
        if currentIndexOfSet >= Int(exercise.sets) {
            /// Sets are completed, mark exercise as completed and jump to next exercise
            exercise.isCompleted = true
            
            /// If there is more exercise, then `nextExercise`, else  `completeTrainingSession`
            if currentStage + 1 >= arrangedExercises.count {
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
    
    /// Reset
    func reset() {
        DispatchQueue.main.async {
            self.currentExercise = nil
            self.startTime = nil
            self.restStartTime = nil
            self.restIntervals = 0
            self.currentStage = 0
            self.currentIndexOfSet = 1
        }
    }

    /// Done
    func done() {
        /// Mark training session is ended
        DispatchQueue.main.async {
            self.isEnd = true
        }
        
        /// Reset
        reset()
        
        /// Update Live Activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.completionType = 1
                await activity.update(.init(state: contentState, staleDate: nil))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.removeActivity()
                }
            }
        }
    }
    
    /// Skip Rest
    func endRest() {
        let newRestStartTime: Date? = nil
        let newRestIntervals: Double? = nil
        
        DispatchQueue.main.async {
            self.restStartTime = newRestStartTime
            self.restIntervals = newRestIntervals
        }
        
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.restStartTime = newRestStartTime
                contentState.restIntervals = newRestIntervals
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
    }
    
    /// Next Set
    func nextSet() {
        /// indexOfSet increased
        let newSetNumber = currentIndexOfSet + 1
        let newRestStartTime = Date.now
        let newRestIntervals = currentExercise?.restIntevals ?? 0
        let newSetsProgress = Double(newSetNumber) / Double(currentExercise?.sets ?? 0)
        
        DispatchQueue.main.async {
            self.currentIndexOfSet = newSetNumber
            self.restStartTime = newRestStartTime
            self.restIntervals = newRestIntervals
            self.currentSetsProgress = newSetsProgress
        }
        
        /// Update Live Activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.indexOfSet = newSetNumber
                contentState.restStartTime = newRestStartTime
                contentState.restIntervals = newRestIntervals
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
    }
    
    /// Next Exericse
    func nextExercise() {
        /// Go to next arranged exercise
        let newStage = currentStage + 1
        let newIndexOfSet = 1
        let newExercise = arrangedExercises[newStage]
        let newRestStartTime = Date.now
        let newRestIntervals = currentExercise?.restIntevals ?? 0
        
        DispatchQueue.main.async {
            self.currentStage = newStage
            self.currentExercise = newExercise
            self.currentIndexOfSet = newIndexOfSet
            self.restStartTime = newRestStartTime
            self.restIntervals = newRestIntervals
        }
        
        /// Update Live Activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.currentStage = newStage
                contentState.currentExerciseID = newExercise.id.uuidString
                contentState.currentExercise = newExercise.exercise.name
                contentState.totalSetsCount = Int(newExercise.sets)
                contentState.indexOfSet = newIndexOfSet
                contentState.weight = newExercise.weight
                contentState.repetition = newExercise.repetitions
                contentState.restStartTime = newRestStartTime
                contentState.restIntervals = newRestIntervals
                
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
    }
}

// MARK: Live Activity
extension TrainingSessionManager {
    /// Add live activity
    func addLiveAcitvity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        /// Gete first exercise
        let firstExercise = arrangedExercises[currentStage]
        self.currentExercise = firstExercise
        
        let trainingSessionAttributes = TrainingSessionAttributes(name: "TrainingSession")
        let initialState = TrainingSessionAttributes.ContentState(totalExerciseCount: arrangedExercises.count,
                                                                  currentStage: currentStage,
                                                                  currentExerciseID: firstExercise.id.uuidString,
                                                                  currentExercise: firstExercise.exercise.name,
                                                                  totalSetsCount: Int(firstExercise.sets),
                                                                  indexOfSet: currentIndexOfSet,
                                                                  weight: firstExercise.weight,
                                                                  repetition: firstExercise.repetitions,
                                                                  completionType: -1,
                                                                  startTime: startTime ?? .now,
                                                                  restStartTime: nil,
                                                                  restIntervals: nil)
        
        do {
            let activity = try Activity<TrainingSessionAttributes>.request(attributes: trainingSessionAttributes,
                                                                           content: .init(state: initialState, staleDate: nil),
                                                                           pushType: nil)
            /// Storing current live activity id for updating activity
            currentLiveActivityID = activity.id
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Delete exising activity
    func removeActivity() {
        ///  Remove  activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
                let finalState = activity.content.state
                await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: dismissalPolicy)
            }
        }
    }
    
    /// Remove all existing live activity
    func removeExistingAcitvity() {
        if let activity = Activity.activities.first(where: {(activity: Activity<TrainingSessionAttributes>) in
                                                       return true
        }) {
            Task {
                let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
                let finalState = activity.content.state
                await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: dismissalPolicy)
            }
        }
    }
}
