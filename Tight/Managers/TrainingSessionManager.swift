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
import AVFoundation
import Combine

/**
 - Countdown timer
 - Based on  Arranged Exercises rest intervals
 -
 */
class TrainingSessionManager: NSObject, ObservableObject {
    /// Singleton
    static let shared = TrainingSessionManager()
    
    let logger = CustomLogger()
    private let healthStore = HKHealthStore()
    var audioPlayer: AVAudioPlayer?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Common Properties
    private(set) var plan: Plan?
    private(set) var arrangedExercises: [ArrangedExercise] = []
    private var currentRestTimeFrame: RestTimeFrame?
    
    @Published var state: TrainingSessionState = .notStarted
    @Published var isRunning: Bool = false
    
    // MARK: Live Activity Properties
    /// Stores the unique identifier of a live activity.
    ///
    /// The `liveActivityID` property is used to hold the unique identifier (ID) associated with a live activity or event. This ID can be utilized to uniquely identify and reference the live activity within your application.
    ///
    /// - Note: Initially, this property is set to an empty string (""). Ensure that it is assigned a valid ID when relevant.
    @Published var liveActivityID: String = ""
    
    /// Represents the currently active or arranged exercise in the training session.
    ///
    /// The `currentExercise` property holds an instance of `ArrangedExercise`, which represents the exercise that is currently being performed or is scheduled to be performed next in the training session.
    ///
    /// - Note: This property may be `nil` if there are no exercises currently active or arranged in the session.
    @Published var currentExercise: ArrangedExercise?
    
    /// Training session's start time
    @Published var startTime: Date?
    
    // MARK: Total Progress Properties
    /// The total number of exercises in the training session.
    @Published var exerciseCount: Int = 0
    
    /// Current stage of whole training session
    @Published var indexOfExercise: Int = 0
    
    /// Current progress value of training session
    @Published var totalProgress: Double = 0
    
    // MARK: Sets Progress Properties
    /// The index indicating the current set of exercises within the training session.
    ///
    /// This property represents the set of exercises currently being performed in a training session.
    /// It starts at 0 for the first set and increments as the session progresses through different sets.
    /// - Note: The value of this property should be non-negative.
    @Published var indexOfSet: Int = 0
    
    /// The percentage completion of sets in the current exercise.
    ///
    /// This property calculates the completion percentage based on the formula:
    /// `exerciseSetCompletionPercentage = Double(exerciseSetIndex) / Double(exercise.sets)`
    ///
    /// - Note: The value of this property ranges from 0.0 (no sets completed) to 1.0 (all sets completed).
    @Published var setsProgress: CGFloat = 0.0
    
    // MARK: Rest Time Properties
    /// Represents the start time of a rest interval during a training session.
    ///
    /// The `restStartTime` property stores the timestamp indicating the start time of a rest period. It is `nil` when there is no ongoing rest period.
    @Published var restStartTime: Date?

    /// Represents the duration of rest intervals during a training session.
    ///
    /// The `restIntervals` property stores the duration, in seconds, of each rest interval. It is `nil` when there are no scheduled rest intervals.
    @Published var restInterval: Double = 0
    
    
    /// Live Activity Content State
    @Published var contentState: TrainingSessionAttributes.ContentState?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        /// Load sound effect and prepare to play
        prepareSoundEffect()
        
        /// Create state observer
        $state.sink { [weak self] newValue in
            /// Change is running or not
            DispatchQueue.main.async {
                self?.isRunning = newValue != .notStarted
            }
        }
        .store(in: &cancellables)
    }
    
    /// Starts a new training session with the given plan and arranged exercises.
    ///
    /// Use this function to initiate a training session by providing a training plan (`plan`) and a list of arranged exercises (`arrangedExercises`).
    ///
    /// - Parameters:
    ///   - plan: The training plan associated with the session, or `nil` if not applicable.
    ///   - arrangedExercises: An array of `ArrangedExercise` instances representing the exercises to be performed in the session.
    ///
    /// This function resets various session-related properties, initializes the session state, and prepares for the training session to begin. It ensures that the necessary information is set up for tracking and recording the session's progress and exercises.
    ///
    /// - Note: The `reset` function should not be used within this function, as it is asynchronous.
    ///
    /// - Precondition: The `arrangedExercises` array must not be empty.
    ///
    /// Example usage:
    /// ```swift
    /// let plan = ... // Provide a training plan, if available
    /// let arrangedExercises = [...] // Provide an array of arranged exercises
    /// startTrainingSession(plan: plan, arrangedExercises: arrangedExercises)
    /// ```
    func startSession(plan: Plan?, arrangedExercises: [ArrangedExercise]) {
        /// Ensure arranged exercise list is not empty
        guard arrangedExercises.isEmpty == false else { return }
        
        let clonedArrangedExercise = arrangedExercises.sorted(by: { $0.order < $1.order })
        
        let currentTime = Date.now
        self.plan = plan
        self.arrangedExercises = clonedArrangedExercise
        self.exerciseCount = clonedArrangedExercise.count
        
        /// Update state  start time and change state
        state = .training
        startTime = currentTime
        
        /// Get first exercise and update start time
        let firstExercise = clonedArrangedExercise[indexOfExercise]
        currentExercise = firstExercise
        currentExercise?.startTime = currentTime
        
        /// Create training log
        createTrainingLog()
        
        /// Add live activity
        createLiveAcitvity()
        
        /// Update `Watch`
        onUpdateWatch()
    }
    
    /// Stops the current training session and performs necessary cleanup.
    ///
    /// Use this function to terminate an ongoing training session, update the session's end time, reset session-related properties, and cancel any scheduled notifications.
    ///
    /// This function transitions the training session state to "aborted," and after a brief delay (2 seconds), it resets the session state to "not started" using a background thread. It also updates the training log's end time, cancels any scheduled notifications, and handles the removal of a live activity if one is associated with the session.
    ///
    /// - Note: Ensure that you call this function when the training session needs to be stopped or aborted.
    ///
    /// Example usage:
    /// ```swift
    /// stopTrainingSession()
    /// ```
    func endSession() {
        /// Cancel all scheduled notification
        cancelScheduledNotifications()
        
        /// Dismiss Live Activity
        dismissLiveActivity()
        
        /// Send end message to Watch
        let state: TrainingSessionState = .notStarted
        TTWCSession.shared.sendMessage([.action: "end", .state: state.rawValue])
        
        /// Update end time to training log
        if let trainingLog = plan?.trainingLog {
            let currentTime = Date.now
            trainingLog.endTime = currentTime
        }
        
        /// Reset Properties
        DispatchQueue.main.async {
            self.state = state
            self.arrangedExercises = []
            self.currentExercise = nil
            self.startTime = nil
            self.restStartTime = nil
            self.restInterval = 0
            self.indexOfExercise = 0
            self.indexOfSet = 0
            self.totalProgress = 0
            self.setsProgress = 0
        }
    }
    
    /// Handles timer actions and manages training session state during rest periods.
    ///
    /// Use this function to check and manage the state of a training session's rest period timer. It verifies if the current time has exceeded the scheduled end time of the rest interval and, if so, performs actions such as updating the training log, resetting rest-related properties, and updating the associated activity.
    ///
    /// This function checks the following conditions:
    /// - Whether `restStartTime` and `restIntervals` are valid values.
    /// - Whether the current time has passed the scheduled end time of the rest interval.
    ///
    /// If these conditions are met, the function updates the training session state to "training," records the end time of the rest time frame in the training log, and resets the rest-related properties. It also triggers a vibration feedback and updates the associated activity's information.
    ///
    /// - Note: Call this function periodically or as needed to manage rest periods within the training session.
    ///
    /// Example usage:
    /// ```swift
    /// handleTimerAction()
    /// ```
    func handleTimerAction() {
        /// Verify the date is over rest end time
        guard let restStartTime = restStartTime else { return }
        
        /// Determine rest time is over or not
        guard Date.now >= restStartTime.addingTimeInterval(restInterval) else { return }
        
        // Haptic Feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        audioPlayer?.play()
        
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
            self.restInterval = 0
            
            /// Update `Live Activity`
            self.onUpdateLiveActivity()
            
            /// Update `Watch`
            self.onUpdateWatch()
        }
    }
    
    /// Completes the current set of the specified exercise and manages the training session progress.
    ///
    /// Use this function to mark the current set of a particular exercise as completed within a training session. It updates the progress of the session and handles scenarios such as moving to the next set of the same exercise or proceeding to the next exercise.
    ///
    /// - Parameters:
    ///   - exerciseID: The unique identifier (UUID string) of the exercise to complete the set for.
    ///
    /// This function performs the following actions:
    /// 1. Locates the corresponding exercise with the provided `exerciseID`.
    /// 2. If the current set is the last set of the exercise, it marks the exercise as completed and determines the next action:
    ///    - If there are more exercises in the session, it proceeds to the next exercise.
    ///    - If there are no more exercises, it completes the entire training session.
    /// 3. If the current set is not the last set, it advances to the next set of the same exercise.
    ///
    /// - Note: Call this function when a set of an exercise is completed during a training session to manage session progress and transitions.
    ///
    /// Example usage:
    /// ```swift
    /// let exerciseID = "12345-ABCDE-..."
    /// completeCurrentSet(exerciseID: exerciseID)
    /// ```
    func completeCurrentSet(exerciseID: String) {
        /// 1. Find the corresponding exercise
        guard let exercise = arrangedExercises.first(where: { $0.id.uuidString == exerciseID }) else { return }
        
        /// 2.
        /// - Go rest
        /// - If there is more set of current exercise, then update the IndexOfSet number
        /// - If there is no more set, then mark it as completed and  jump to next exercise
        /// - If there is no next exercise, then complete the training session
        if indexOfSet >= Int(exercise.sets - 1) {
            /// Sets are completed, mark exercise as completed and jump to next exercise
            exercise.isCompleted = true
            
            /// If there is more exercise, then `nextExercise`, else  `completeTrainingSession`
            if indexOfExercise + 1 >= arrangedExercises.count {
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
            self.setsProgress = progress
            self.totalProgress = progress
            
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
        let currentTime = Date.now
        let newRestStartTime: Date? = nil
        let newRestIntervals: Double = 0
        let newState: TrainingSessionState = .training
        
        /// Process task for rest time end
        if let plan = plan, let restTimeFrame = currentRestTimeFrame {
            onRestTimeEnd(currentTime: currentTime, plan: plan, restTimeFrame: restTimeFrame)
        }
        
        DispatchQueue.main.async {
            self.restStartTime = newRestStartTime
            self.restInterval = newRestIntervals
            self.state = newState
            
            /// Update live activity
            self.onUpdateLiveActivity()
            
            /// Update Watch
            self.onUpdateWatch()
        }
    }
    
    /// Next Set
    func nextSet() {
        let currentTime = Date.now
        
        /// Init new values
        let newState: TrainingSessionState = .resting
        let newIndexOfSet = indexOfSet + 1
        let newRestInterval = currentExercise?.restIntevals ?? 0
        let newSetsProgress = Double(newIndexOfSet) / Double(currentExercise?.sets ?? 0)
        
        /// Process task for rest time start
        currentRestTimeFrame = onRestTimeStart(currentTime: currentTime, restTimeInterval: newRestInterval)
        
        DispatchQueue.main.async {
            self.state = newState
            self.indexOfSet = newIndexOfSet
            self.restStartTime = currentTime
            self.restInterval = newRestInterval
            self.setsProgress = newSetsProgress
            
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
        let newState: TrainingSessionState = .resting
        let currentTime = Date.now
        
        /// New  progress
        let newIndexOfExercise = indexOfExercise + 1
        let newIndexOfSet = 0
        let newSetsProgress = 0.0
        
        /// Set `currentTime` to new current exercise's `startTime`
        let newExercise = arrangedExercises[newIndexOfExercise]
        newExercise.startTime = currentTime
        
        /// Create new rest time frame and set `startTime`
        let newRestInterval = newExercise.restIntevals
        
        /// Create new rest time frame and set `startTime`
        currentRestTimeFrame = onRestTimeStart(currentTime: currentTime, restTimeInterval: newRestInterval)
        
        /// Wait for `0.7` secs and shift to next exercise
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.state = newState
            self.indexOfExercise = newIndexOfExercise
            self.currentExercise = newExercise
            self.indexOfSet = newIndexOfSet
            self.restStartTime = currentTime
            self.restInterval = newExercise.restIntevals
            self.setsProgress = newSetsProgress
            self.totalProgress = self.calculateProgress(index: newIndexOfExercise, totalCount: self.exerciseCount)
            
            /// Update Live Activity
            self.onUpdateLiveActivity()
            
            /// Send message to Watch
            self.onUpdateWatch()
        }
    }
}

// MARK: Training Log
extension TrainingSessionManager {
    func createTrainingLog() {
        /// - Create a training log if it's not existed or update existing one
        /// - Set  `currentTime` to  current exercise's `startTime`
        let currentTime = Date.now
        let trainingLog = TrainingLog(startTime: currentTime)
        trainingLog.startTime = currentTime
        plan?.trainingLog = trainingLog
    }
}

// MARK: Rest Time Handler
extension TrainingSessionManager {
    func onRestTimeStart(currentTime: Date, restTimeInterval: TimeInterval) -> RestTimeFrame {
        /// Schedule a rest time notification
        scheduleNotification(timeInterval: restTimeInterval)
        
        return RestTimeFrame(startTime: currentTime)
    }
    
    func onRestTimeEnd(currentTime: Date, plan: Plan, restTimeFrame: RestTimeFrame) {
        /// Set `endTime` to current rest time frame and save to `trainingLog`
        restTimeFrame.endTime = currentTime
        plan.trainingLog?.restTimeFrames.append(restTimeFrame)
        
        /// Cancel all scheduled notification
        cancelScheduledNotifications()
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
        currentExercise?.endTime = currentTime
        
        /// Update `progress`
        let newSetsProgress = 1.0
        DispatchQueue.main.async {
            self.setsProgress = newSetsProgress
            
            /// Update `Live Activity`
            self.onUpdateLiveActivity()
            
            /// Update `Watch`
            self.onUpdateWatch()
        }
    }
}
