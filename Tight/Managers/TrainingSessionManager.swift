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
    @Published var currentLiveActivityID: String = ""
    @Published var currentStage: Int = 0
    
    static let shared = TrainingSessionManager()
    
    /// Configure arranged exercises
    /// NOTE:  Invoke this function before start the training session
    func configure(arrangedExercises: [ArrangedExercise]) {
        /// End and remove existing live activtiy   
        
        self.arrangedExercises = arrangedExercises
        self.currentStage = 0
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
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.async {
            self.elapsedTime = 0
        }
        
        /// End current live activity
        removeActivity()
    }
    
    /// Handle function when timer tiggered it
    func handleTimerAction() {
        ///  Add 1 second
        let newElapsedTime: TimeInterval = elapsedTime + 1.0
        DispatchQueue.main.async {
            self.elapsedTime = newElapsedTime
        }
        
        ///  Find activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.elapsedTime = newElapsedTime
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
    }
    
    /// Complete current exercise
    func completeCurrentExercise(exerciseID: String) {        
        /// Mark it as completed
        if let exercise = arrangedExercises.first(where: { $0.id.uuidString == exerciseID }) {
            exercise.isCompleted.toggle()
        }
        
        /// Stop training sessio if there is not more stage
        if currentStage + 1 >= arrangedExercises.count  {
            stopTrainingSession()
            return
        }
        
        /// Go to next arranged exercise
        let newStage = currentStage + 1
        let currentExercise = arrangedExercises[newStage]
        let nextExercise = newStage + 1 >= arrangedExercises.count ? "" : arrangedExercises[newStage + 1].exercise.name
        
        DispatchQueue.main.async {
            self.currentStage = newStage
        }
        
        ///  Find activity
        if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
            activity.id == currentLiveActivityID
        }) {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.currentStage = newStage
                contentState.currentExerciseID = currentExercise.id.uuidString
                contentState.currentExercise = currentExercise.exercise.name
                contentState.nextExercise = nextExercise
                contentState.weight = currentExercise.weight
                contentState.repetition = currentExercise.repetitions
                contentState.restInterval = currentExercise.restIntevals
                
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
        
    }
    
    /// Add live activity
    func addLiveAcitvity() {
        let trainingSessionAttributes = TrainingSessionAttributes(name: "TrainingSession")
        let currentExercise = arrangedExercises[currentStage]
        let nextExercise = currentStage + 1 >= arrangedExercises.count ? "" : arrangedExercises[currentStage + 1].exercise.name
        let initialState = TrainingSessionAttributes.ContentState(totalExerciseCount: arrangedExercises.count,
                                                                  currentStage: currentStage,
                                                                  currentExerciseID: currentExercise.id.uuidString,
                                                                  currentExercise: currentExercise.exercise.name,
                                                                  nextExercise: nextExercise,
                                                                  weight: currentExercise.weight,
                                                                  repetition: currentExercise.repetitions,
                                                                  restInterval: currentExercise.restIntevals,
                                                                  elapsedTime: elapsedTime)
        
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
