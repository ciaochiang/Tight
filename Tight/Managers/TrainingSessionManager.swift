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

enum TraningSessionState {
    case notStarted
    case training
    case resting
    case aborted
    case finshed
}

/**
 - Countdown timer
 - Based on  Arranged Exercises rest intervals
 -
 */

class TrainingSessionManager: ObservableObject {
    private(set) var arrangedExercises: [ArrangedExercise] = []
    
    /// Live Activity Properties
    @Published var state: TraningSessionState = .notStarted
    @Published var currentLiveActivityID: String = ""
    @Published var currentExercise: ArrangedExercise?
    @Published private var totalExerciseCount: Int = 0
    @Published private var currentStage: Int = 0
    @Published var currentProgress: Double = 0
    @Published var currentIndexOfSet: Int = 0
    @Published var currentSetsProgress: Double = 0.0
    @Published var startTime: Date?
    @Published var restStartTime: Date?
    @Published var restIntervals: Double?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    static let shared = TrainingSessionManager()
    
    /// Start Training Session
    func startTrainingSession(arrangedExercises: [ArrangedExercise]) {
        /// NOTE: Do not use `reset` function here given that is async function
        self.currentExercise = nil
        self.startTime = nil
        self.restStartTime = nil
        self.restIntervals = 0
        self.currentStage = 0
        self.currentIndexOfSet = 0
        self.currentProgress = 0
        
        /// Ensure arranged exercise list is not empty
        guard arrangedExercises.isEmpty == false else { return }
        
        self.arrangedExercises = arrangedExercises
        self.totalExerciseCount = arrangedExercises.count
        
        /// Gete first exercise
        let firstExercise = arrangedExercises[currentStage]
        self.currentExercise = firstExercise
        self.currentSetsProgress = Double(currentIndexOfSet) / Double(firstExercise.sets)
        
        /// Remove existing activity
        removeExistingAcitvity()
        
        /// Init start time and change state
        startTime = Date.now
        state = .training
        
        /// Add live activity
        addLiveAcitvity()
    }
    
    /// Stop Training Session
    func stopTrainingSession() {
        let newState: TraningSessionState = .aborted

        DispatchQueue.main.async {
            self.state = newState
        }
        
        /// Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.state = .notStarted
        })
        
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
                    Task {
                        let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
                        let finalState = activity.content.state
                        await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: dismissalPolicy)
                    }
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
        
        let newState: TraningSessionState = .training
        
        /// Reset rest time
        DispatchQueue.main.async {
            self.state = newState
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
        if currentIndexOfSet >= Int(exercise.sets - 1) {
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
            self.currentIndexOfSet = 0
        }
    }

    /// Done
    func done() {
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
                
                /// Remove activity
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    Task {
                        let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
                        let finalState = activity.content.state
                        await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: dismissalPolicy)
                    }
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
        let newState: TraningSessionState = .resting
        let newSetNumber = currentIndexOfSet + 1
        let newRestStartTime = Date.now
        let newRestIntervals = currentExercise?.restIntevals ?? 0
        let newSetsProgress = Double(newSetNumber) / Double(currentExercise?.sets ?? 0)
        
        DispatchQueue.main.async {
            self.state = newState
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
        let newState: TraningSessionState = .resting
        let newStage = currentStage + 1
        let newIndexOfSet = 0
        let newExercise = arrangedExercises[newStage]
        let newRestStartTime = Date.now
        let newRestIntervals = currentExercise?.restIntevals ?? 0
        let newSetsProgress = 0.0
        let newProgress = Double(newStage) / Double(totalExerciseCount)
        
        DispatchQueue.main.async {
            self.state = newState
            self.currentStage = newStage
            self.currentExercise = newExercise
            self.currentIndexOfSet = newIndexOfSet
            self.restStartTime = newRestStartTime
            self.restIntervals = newRestIntervals
            self.currentSetsProgress = newSetsProgress
            self.currentProgress = newProgress
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
                contentState.currentExerciseName = newExercise.exercise.name
                contentState.currentStage = newStage
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
        guard ActivityAuthorizationInfo().areActivitiesEnabled, let firstExercise = currentExercise else { return }
        
        let trainingSessionAttributes = TrainingSessionAttributes(name: "TrainingSession")
        let initialState = TrainingSessionAttributes.ContentState(currentExerciseID: firstExercise.id.uuidString,
                                                                  currentExerciseName: firstExercise.exercise.name,
                                                                  weight: firstExercise.weight,
                                                                  repetition: firstExercise.repetitions,
                                                                  startTime: startTime ?? .now,
                                                                  restStartTime: nil,
                                                                  restIntervals: nil,
                                                                  indexOfSet: currentIndexOfSet,
                                                                  currentSetsProgress: currentSetsProgress,
                                                                  totalExerciseCount: totalExerciseCount,
                                                                  currentStage: currentStage, 
                                                                  completionType: -1)
        
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
