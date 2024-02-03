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
    func createLiveAcitvity(startTime: Date, exercise: ArrangedExercise) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let liveActivityAttributes = LiveActivityAttributes()
        contentState = LiveActivityAttributes.ContentState(state: content.state.rawValue,
                                                              startTime: startTime,
                                                              currentExerciseID: exercise.id.uuidString,
                                                              exerciseName: exercise.exercise.name,
                                                              weight: exercise.weight,
                                                              weightUnit: exercise.weightUnit,
                                                              repetitions: exercise.repetitions,
                                                              restStartTime: content.restStartTime ?? .now,
                                                              restInterval: content.restInterval,
                                                              indexOfSet: content.indexOfSet,
                                                              setsProgress: content.setsProgress,
                                                              totalProgress: content.totalProgress)
        guard let contentState = contentState else { return }
        
        do {
            let activity = try Activity<LiveActivityAttributes>.request(attributes: liveActivityAttributes,
                                                                           content: .init(state: contentState, staleDate: nil),
                                                                           pushType: nil)
            /// Storing current live activity id for updating activity
            content.liveActivityID = activity.id
        } catch {
            logger.log(error.localizedDescription, level: .error)
        }
    }
    
    /// Update `Live Activity`
    func onUpdateLiveActivity() {
        guard let exercise = content.currentExercise, let startTime = content.startTime else { return }
        guard let activity = Activity<LiveActivityAttributes>.activities.first else { return }
        
        Task {
            /// Update activity info
            var contentState = activity.content.state
            contentState.state = content.state.rawValue
            contentState.startTime = startTime
            contentState.currentExerciseID = exercise.id.uuidString
            contentState.exerciseName = exercise.exercise.name
            contentState.totalProgress = content.totalProgress
            contentState.indexOfSet = content.indexOfSet
            contentState.setsProgress = content.setsProgress
            contentState.weight = exercise.weight
            contentState.weightUnit = exercise.weightUnit
            contentState.repetitions = exercise.repetitions
            contentState.restStartTime = content.restStartTime ?? .now
            contentState.restInterval = content.restInterval
            
            await activity.update(.init(state: contentState, staleDate: nil))
        }
    }
    
    /// Update `Live Activity`
    func onUpdateLiveActivity(content: TrainingSessionContent) {
        guard let exercise = content.currentExercise, let startTime = content.startTime else { return }
        
        if let activity = Activity<LiveActivityAttributes>.activities.first {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.state = content.state.rawValue
                contentState.startTime = startTime
                contentState.currentExerciseID = exercise.id.uuidString
                contentState.exerciseName = exercise.exercise.name
                contentState.totalProgress = content.totalProgress
                contentState.indexOfSet = content.indexOfSet
                contentState.setsProgress = content.setsProgress
                contentState.weight = exercise.weight
                contentState.weightUnit = exercise.weightUnit
                contentState.repetitions = exercise.repetitions
                contentState.restStartTime = content.restStartTime ?? .now
                contentState.restInterval = content.restInterval
                
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
    }
    
    /// Remove all existing live activity
    func dismissLiveActivity() {
        Task {
           for activity in Activity<LiveActivityAttributes>.activities {
                let finalState = activity.content.state
                await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            }
        }
    }
}
