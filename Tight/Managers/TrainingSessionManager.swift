//
//  TrainingSessionManager.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/3.
//

import Foundation
import SwiftUI
import ActivityKit
import UserNotifications

enum TrainingSessionState {
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
    private(set) var plan: Plan?
    private(set) var arrangedExercises: [ArrangedExercise] = []
    private var currentRestTimeFrame: RestTimeFrame?
    private var logger = CustomLogger()
    
    /// Live Activity Properties
    @Published var state: TrainingSessionState = .notStarted
    @Published var currentLiveActivityID: String = ""
    @Published var currentExercise: ArrangedExercise?
    @Published var totalExerciseCount: Int = 0
    @Published private var currentStage: Int = 0
    @Published var currentProgress: Double = 0
    @Published var currentIndexOfSet: Int = 0
    @Published var currentSetsProgress: Double = 0.0
    @Published var startTime: Date?
    @Published var restStartTime: Date?
    @Published var restIntervals: Double?
    @Published var isRunning: Bool = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    static let shared = TrainingSessionManager()
    
    /// Start Training Session
    func startTrainingSession(plan: Plan?, arrangedExercises: [ArrangedExercise]) {
        /// NOTE: Do not use `reset` function here given that is async function
        self.currentExercise = nil
        self.startTime = nil
        self.restStartTime = nil
        self.restIntervals = 0
        self.currentStage = 0
        self.currentIndexOfSet = 0
        self.currentProgress = 0
        self.isRunning = true
        
        /// Ensure arranged exercise list is not empty
        guard arrangedExercises.isEmpty == false else { return }
        
        self.plan = plan
        self.arrangedExercises = arrangedExercises
        self.totalExerciseCount = arrangedExercises.count
        
        /// Gete first exercise
        let firstExercise = arrangedExercises[currentStage]
        self.currentExercise = firstExercise
        self.currentSetsProgress = Double(currentIndexOfSet) / Double(firstExercise.sets)
        
        /// - Create a training log if it's not existed or update existing one
        /// - Set  `currentTime` to  current exercise's `startTime`
        let currentTime = Date.now
        if let trainingLog = plan?.trainingLog {
            trainingLog.startTime = currentTime
        } else {
            let trainingLog = TrainingLog(startTime: currentTime)
            plan?.trainingLog = trainingLog
        }
        currentExercise?.startTime = currentTime
        
        /// Remove existing activity
        removeExistingAcitvity()
        
        /// Init start time and change state
        startTime = currentTime
        state = .training
        
        /// Add live activity
        addLiveAcitvity()
    }
    
    /// Stop Training Session
    func stopTrainingSession() {
        let newState: TrainingSessionState = .aborted
        let currentTime = Date.now

        DispatchQueue.main.async {
            self.state = newState
            self.isRunning = false
        }
        
        /// Update end time to training log
        if let trainingLog = plan?.trainingLog {
            trainingLog.endTime = currentTime
        }
        
        /// Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.state = .notStarted
        })
        reset()
        
        /// Cancel scheduled notifications
        cancelScheduledNotifications()
        
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
        
        let currentTime = Date.now
        let newState: TrainingSessionState = .training
        
        /// Set `endTime` to current rest time frame and save to `trainingLog`
        currentRestTimeFrame?.endTime = currentTime
        if let restTimeFrame = currentRestTimeFrame {
            plan?.trainingLog?.restTimeFrames.append(restTimeFrame)
        }
        
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

                /// Mark out temp, because it's causing duplicated notification with scheduled notification.
//                /// If rest time up, then alerting, if not, then just normal update
//                let alertConfig = AlertConfiguration(
//                    title: "\(LocalizationProvider.notificationRestTimeDoneTitle.stringValue)",
//                    body: "\(LocalizationProvider.notificationRestTimeDoneDescription.stringValue)",
//                    sound: .default
//                )
//                
                /// Vibrate
                await UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                await activity.update(.init(state: contentState, staleDate: nil), alertConfiguration: nil)
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
        /// Set `endTime` to `trainingLog`
        let currentTime = Date.now
        plan?.trainingLog?.endTime = currentTime
        
        /// Update current progress to completed
        DispatchQueue.main.async {
            self.currentSetsProgress = 1.0
            self.currentProgress = 1.0
        }
        
        /// Cancel all scheduled notification
        cancelScheduledNotifications()
        
        /// Stop and Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.isRunning = false
            
            /// Reset
            self.reset()
        }
        
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
        let currentTime = Date.now
        let newRestStartTime: Date? = nil
        let newRestIntervals: Double? = nil
        let newState: TrainingSessionState = .training
        
        /// Set `endTime` to current rest time frame and save to `trainingLog`
        currentRestTimeFrame?.endTime = currentTime
        if let restTimeFrame = currentRestTimeFrame {
            plan?.trainingLog?.restTimeFrames.append(restTimeFrame)
        }
        
        /// Cancel schedule notification
        cancelScheduledNotifications()
        
        DispatchQueue.main.async {
            self.restStartTime = newRestStartTime
            self.restIntervals = newRestIntervals
            self.state = newState
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
        let currentTime = Date.now
        
        /// indexOfSet increased
        let newState: TrainingSessionState = .resting
        let newSetNumber = currentIndexOfSet + 1
        let newRestIntervals = currentExercise?.restIntevals ?? 0
        let newSetsProgress = Double(newSetNumber) / Double(currentExercise?.sets ?? 0)
        
        /// Create new rest time frame and set `startTime`
        currentRestTimeFrame = RestTimeFrame(startTime: currentTime)
        
        /// Schedule a rest time notification
        scheduleNotification(timeInterval: newRestIntervals)
        
        DispatchQueue.main.async {
            self.state = newState
            self.currentIndexOfSet = newSetNumber
            self.restStartTime = currentTime
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
                contentState.currentSetsProgress = newSetsProgress
                contentState.restStartTime = currentTime
                contentState.restIntervals = newRestIntervals
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
    }
    
    /// Next Exericse
    func nextExercise() {
        /// Update current exercise/set progress
        let completedSetsProgress = 1.0
        DispatchQueue.main.async {
            self.currentSetsProgress = completedSetsProgress
            
            /// Update Live Activity
            if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
                activity.id == self.currentLiveActivityID
            }) {
                Task {
                    /// Update activity info
                    var contentState = activity.content.state
                    contentState.currentSetsProgress = completedSetsProgress
                    await activity.update(.init(state: contentState, staleDate: nil))
                }
            }
        }
        
        /// Go to next arranged exercise
        let newState: TrainingSessionState = .resting
        let newStage = currentStage + 1
        let newIndexOfSet = 0
        
        /// Set `currentTime` to current exercise's `endTime`
        let currentTime = Date.now
        currentExercise?.endTime = currentTime
        
        /// Set `currentTime` to new current exercise's `startTime`
        let newExercise = arrangedExercises[newStage]
        newExercise.startTime = currentTime
        
        /// Create new rest time frame and set `startTime`
        currentRestTimeFrame = RestTimeFrame(startTime: currentTime)
        
        let newRestStartTime = Date.now
        let newRestIntervals = currentExercise?.restIntevals ?? 0
        let newSetsProgress = 0.0
        let newProgress = Double(newStage) / Double(totalExerciseCount)
        
        /// Schedule rest time notification
        scheduleNotification(timeInterval: newRestIntervals)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.state = newState
            self.currentStage = newStage
            self.currentExercise = newExercise
            self.currentIndexOfSet = newIndexOfSet
            self.restStartTime = newRestStartTime
            self.restIntervals = newRestIntervals
            self.currentSetsProgress = newSetsProgress
            self.currentProgress = newProgress
            
            /// Update Live Activity
            if let activity = Activity.activities.first(where: { (activity: Activity<TrainingSessionAttributes>) in
                activity.id == self.currentLiveActivityID
            }) {
                Task {
                    /// Update activity info
                    var contentState = activity.content.state
                    contentState.currentStage = newStage
                    contentState.currentExerciseID = newExercise.id.uuidString
                    contentState.currentExerciseName = newExercise.exercise.name
                    contentState.currentStage = newStage
                    contentState.indexOfSet = newIndexOfSet
                    contentState.currentSetsProgress = newSetsProgress
                    contentState.weight = newExercise.weight
                    contentState.repetition = newExercise.repetitions
                    contentState.restStartTime = newRestStartTime
                    contentState.restIntervals = newRestIntervals
                    
                    await activity.update(.init(state: contentState, staleDate: nil))
                }
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

// MARK: Local Notification
extension TrainingSessionManager {
    func scheduleNotification(timeInterval: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                // Permission granted
                let content = UNMutableNotificationContent()
                content.title = LocalizationProvider.notificationRestTimeDoneTitle.stringValue
                content.body = LocalizationProvider.notificationRestTimeDoneDescription.stringValue
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
                
                let request = UNNotificationRequest(identifier: Constants.NOTIFICATION_IDENTIFIER_TRAINING_SESSION, content: content, trigger: trigger)
                
                let center = UNUserNotificationCenter.current()
                center.add(request) { (error) in
                    if let error = error {
                        // Handle any errors here.
                        self.logger.log(error.localizedDescription, level: .error)
                    }
                }
            } else if let error = error {
                // Handle the case where permission is denied or there is an error.
                self.logger.log(error.localizedDescription, level: .error)
            }
        }
    }
    
    func cancelScheduledNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Constants.NOTIFICATION_IDENTIFIER_TRAINING_SESSION])
    }
}
