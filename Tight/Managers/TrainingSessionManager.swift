//
//  TrainingSessionManager.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/3.
//

import Foundation
import SwiftUI
import ActivityKit

/**
 - Countdown timer
 - Based on  Arranged Exercises rest intervals
 -
 */

class TrainingSessionManager: ObservableObject {
    private var arrangedExercises: [ArrangedExercise] = []
    private var timer: Timer?
    
    @Published var elapsedTime: TimeInterval = 0
    
    /// Live Activity Properties
    @Published var currentLiveActivityID: String = ""
    @Published var currentExercise: ArrangedExercise?
    @Published var currentStage: Int = 0
    @Published var currentIndexOfSet: Int = 1
    @Published var currentRestIntervals: TimeInterval = 0
    
    static let shared = TrainingSessionManager()
    
    /// Configure arranged exercises
    /// NOTE:  Invoke this function before start the training session
    func configure(arrangedExercises: [ArrangedExercise]) {
        /// End and remove existing live activtiy   
        
        self.arrangedExercises = arrangedExercises
        self.currentStage = 0
        self.currentIndexOfSet = 1
    }
    
    /// Start Training Session
    func startTrainingSession() {
        /// Ensure arranged exercise list is not empty
        guard arrangedExercises.isEmpty == false else { return }
        
        /// Remove activity
        removeActivity()
        
        /// Init the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            self?.handleTimerAction()
        })
        
        /// Add live activity
        addLiveAcitvity()
    }
    
    /// Stop Training Session
    func stopTrainingSession() {
        /// Reset
        reset()
        
        /// Find activity
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
        /// Add 1 second
        let newElapsedTime: TimeInterval = elapsedTime + 1.0
        
        /// Handle resting
        let isResting = currentRestIntervals > 0
        let remianRestInterval = currentRestIntervals
        let newRestIntervals = isResting ? currentRestIntervals - 1 : 0
        
        DispatchQueue.main.async {
            self.elapsedTime = newElapsedTime
            self.currentRestIntervals = newRestIntervals
        }
        
        ///  Find activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.elapsedTime = newElapsedTime
                contentState.restIntervals = newRestIntervals
                
                /// If rest time up, then alerting, if not, then just normal update
                var alertConfig: AlertConfiguration? = nil
                if remianRestInterval == 1 && newRestIntervals == 0 {
                    alertConfig = AlertConfiguration(
                        title: "Break Time is Over!",
                        body: "Let's go for next set",
                        sound: .default
                    )
                    
                    /// Vibrate
                    await UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                
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
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.async {
            self.currentExercise = nil
            self.elapsedTime = 0
            self.currentStage = 0
            self.currentIndexOfSet = 1
            self.currentRestIntervals = 0
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.removeActivity()
                }
            }
        }
    }
    
    /// Skip Rest
    func skipRest() {
        let newRestInterval: TimeInterval = 0
        DispatchQueue.main.async {
            self.currentRestIntervals = newRestInterval
        }
        
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.restIntervals = newRestInterval
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
    }
    
    /// Next Set
    func nextSet() {
        /// indexOfSet increased
        let newSetNumber = currentIndexOfSet + 1
        let newRestIntervals = currentExercise?.restIntevals ?? 0
        
        DispatchQueue.main.async {
            self.currentIndexOfSet = newSetNumber
            self.currentRestIntervals = newRestIntervals
        }
        
        /// Update Live Activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.indexOfSet = newSetNumber
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
        let currentExerciseRestInterval = currentExercise?.restIntevals ?? 0
        
        DispatchQueue.main.async {
            self.currentStage = newStage
            self.currentExercise = newExercise
            self.currentIndexOfSet = newIndexOfSet
            self.currentRestIntervals = newExercise.restIntevals
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
                contentState.restIntervals = currentExerciseRestInterval
                
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
                                                                  restIntervals: 0,     /// No rest interval at initial state
                                                                  elapsedTime: elapsedTime,
                                                                  completionType: -1)    /// -1 is initial state)
        
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
        ///  Find activity
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
}
