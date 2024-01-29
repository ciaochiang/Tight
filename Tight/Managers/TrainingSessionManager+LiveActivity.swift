//
//  TrainingSessionManager+LiveActivity.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/29.
//

import Foundation
import ActivityKit

// MARK: Live Activity
extension TrainingSessionManager {
    /// Add live activity
    func createLiveAcitvity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled, let exercise = currentExercise, let startTime = startTime else { return }
        
        let trainingSessionAttributes = TrainingSessionAttributes()
        contentState = TrainingSessionAttributes.ContentState(state: state.rawValue,
                                                              startTime: startTime,
                                                              currentExerciseID: exercise.id.uuidString,
                                                              exerciseName: exercise.exercise.name,
                                                              weight: exercise.weight,
                                                              weightUnit: exercise.weightUnit,
                                                              repetitions: exercise.repetitions,
                                                              restInterval: restInterval,
                                                              indexOfSet: indexOfSet,
                                                              setsProgress: setsProgress,
                                                              totalProgress: totalProgress)
        guard let contentState = contentState else { return }
        
        do {
            let activity = try Activity<TrainingSessionAttributes>.request(attributes: trainingSessionAttributes,
                                                                           content: .init(state: contentState, staleDate: nil),
                                                                           pushType: nil)
            /// Storing current live activity id for updating activity
            liveActivityID = activity.id
        } catch {
            logger.log(error.localizedDescription, level: .error)
        }
    }
    
    /// Update `Live Activity`
    func onUpdateLiveActivity() {
        guard let exercise = currentExercise, let startTime = startTime else { return }
        
        if let activity = Activity<TrainingSessionAttributes>.activities.first {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.state = state.rawValue
                contentState.startTime = startTime
                contentState.currentExerciseID = exercise.id.uuidString
                contentState.exerciseName = exercise.exercise.name
                contentState.totalProgress = totalProgress
                contentState.indexOfSet = indexOfSet
                contentState.setsProgress = setsProgress
                contentState.weight = exercise.weight
                contentState.weightUnit = exercise.weightUnit
                contentState.repetitions = exercise.repetitions
                contentState.restStartTime = restStartTime ?? .now
                contentState.restInterval = restInterval
                
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
        
    }
    
    /// Remove all existing live activity
    func dismissLiveActivity() {
        Task {
           for activity in Activity<TrainingSessionAttributes>.activities {
                let finalState = activity.content.state
                await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            }
        }
    }
}
