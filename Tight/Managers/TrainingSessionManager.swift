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
import WatchConnectivity
import HealthKit
import AVFoundation

/**
 - Countdown timer
 - Based on  Arranged Exercises rest intervals
 -
 */
class TrainingSessionManager: NSObject, ObservableObject {
    /// Singleton
    static let shared = TrainingSessionManager()
    
    /// Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Common Properties
    private(set) var plan: Plan?
    private(set) var arrangedExercises: [ArrangedExercise] = []
    private var currentRestTimeFrame: RestTimeFrame?
    private var logger = CustomLogger()
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
    
    /// The total number of exercises in the training session.
    @Published var exerciseCount: Int = 0
    
    /// Training session's start time
    @Published var startTime: Date?
    
    /// Current stage of whole training session
    @Published var sessionStage: Int = 0
    
    /// Current progress value of training session
    @Published var sessionProgress: Double = 0
    
    /// The index indicating the current set of exercises within the training session.
    ///
    /// This property represents the set of exercises currently being performed in a training session.
    /// It starts at 0 for the first set and increments as the session progresses through different sets.
    /// - Note: The value of this property should be non-negative.
    @Published var exerciseSetIndex: Int = 0
    
    /// The percentage completion of sets in the current exercise.
    ///
    /// This property calculates the completion percentage based on the formula:
    /// `exerciseSetCompletionPercentage = Double(exerciseSetIndex) / Double(exercise.sets)`
    ///
    /// - Note: The value of this property ranges from 0.0 (no sets completed) to 1.0 (all sets completed).
    @Published var exerciseSetCompletionProgress: CGFloat = 0.0
    
    // MARK: Rest Time
    /// Represents the start time of a rest interval during a training session.
    ///
    /// The `restStartTime` property stores the timestamp indicating the start time of a rest period. It is `nil` when there is no ongoing rest period.
    @Published var restStartTime: Date?

    /// Represents the duration of rest intervals during a training session.
    ///
    /// The `restIntervals` property stores the duration, in seconds, of each rest interval. It is `nil` when there are no scheduled rest intervals.
    @Published var restIntervals: Double?
    
    @Published var contentState: TrainingSessionAttributes.ContentState?
    
    /// Health Kit
    let healthStore = HKHealthStore()
    
    /// Sound
    private var audioPlayer: AVAudioPlayer?

    
    override init() {
        super.init()
        
        prepareSoundEffect()
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
    func startTrainingSession(plan: Plan?, arrangedExercises: [ArrangedExercise]) {
        /// NOTE: Do not use `reset` function here given that is async function
        self.arrangedExercises = []
        self.currentExercise = nil
        self.startTime = nil
        self.restStartTime = nil
        self.restIntervals = 0
        self.sessionStage = 0
        self.exerciseSetIndex = 0
        self.sessionProgress = 0
        self.isRunning = true
                
        /// Ensure arranged exercise list is not empty
        guard arrangedExercises.isEmpty == false else { return }
        
        let clonedArrangedExercise = arrangedExercises.sorted(by: { $0.order < $1.order })
        
        self.plan = plan
        self.arrangedExercises = clonedArrangedExercise
        self.exerciseCount = clonedArrangedExercise.count
        
        /// Gete first exercise
        let firstExercise = clonedArrangedExercise[sessionStage]
        self.currentExercise = firstExercise
        self.exerciseSetCompletionProgress = Double(exerciseSetIndex) / Double(firstExercise.sets)
        
        /// - Create a training log if it's not existed or update existing one
        /// - Set  `currentTime` to  current exercise's `startTime`
        let currentTime = Date.now
        let trainingLog = TrainingLog(startTime: currentTime)
        trainingLog.startTime = currentTime
        plan?.trainingLog = trainingLog
        currentExercise?.startTime = currentTime
        
        /// Remove existing activity
        removeExistingAcitvity()
        
        /// Init start time and change state
        startTime = currentTime
        state = .training
        
        /// Add live activity
        addLiveAcitvity()
        
        /// Send message to Watch
        sendWatchMessage(message: ["state": state.rawValue,
                                   "currentExerciseID": firstExercise.id.uuidString,
                                   "exerciseName": firstExercise.exercise.name,
                                   "startTime": startTime ?? .now,
                                   "weight": firstExercise.weight,
                                   "weightUnit": firstExercise.weightUnit,
                                   "repetitions": firstExercise.repetitions,
                                   "indexOfSet": exerciseSetIndex,
                                   "currentSetsProgress": exerciseSetCompletionProgress
                                  ])
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
    func stopTrainingSession() {
        let newState: TrainingSessionState = .aborted
        let currentTime = Date.now

        DispatchQueue.main.async {
            self.state = newState
            self.isRunning = false
        }
        
        /// Send message to Watch
        self.sendWatchMessage(message: ["state": newState.rawValue])
        
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
        if let activity = Activity<TrainingSessionAttributes>.activities.first {
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
        guard let restStartTime = restStartTime, let restInterval = restIntervals else { return }
        
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
            self.restIntervals = nil
        }
        
        ///  Update activity
        if let activity = Activity<TrainingSessionAttributes>.activities.first {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.restStartTime = nil
                contentState.restIntervals = nil
                
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
        
        /// Send message to Watch
        sendWatchMessage(message: ["state": newState.rawValue,
                                   "restStartTime": Date.now,
                                   "restIntervals": 0
                                  ])
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
        if exerciseSetIndex >= Int(exercise.sets - 1) {
            /// Sets are completed, mark exercise as completed and jump to next exercise
            exercise.isCompleted = true
            
            /// If there is more exercise, then `nextExercise`, else  `completeTrainingSession`
            if sessionStage + 1 >= arrangedExercises.count {
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
        let newState: TrainingSessionState = .notStarted
        
        DispatchQueue.main.async {
            self.state = newState
            self.currentExercise = nil
            self.startTime = nil
            self.restStartTime = nil
            self.restIntervals = 0
            self.sessionStage = 0
            self.exerciseSetIndex = 0
        }
        
        /// Send message to Watch
        self.sendWatchMessage(message: ["state": newState.rawValue])
    }

    /// Done
    func done() {
        let newState: TrainingSessionState = .finshed

        /// Set `endTime` to `trainingLog`
        let currentTime = Date.now
        plan?.trainingLog?.endTime = currentTime
        
        /// Update current progress to completed
        DispatchQueue.main.async {
            self.exerciseSetCompletionProgress = 1.0
            self.sessionProgress = 1.0
            self.state = newState
            
            /// Send message to Watch
            self.sendWatchMessage(message: ["state": newState.rawValue, "currentSetsProgress": 1.0])
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
        if let activity = Activity<TrainingSessionAttributes>.activities.first {
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
        
        if let activity = Activity<TrainingSessionAttributes>.activities.first {
            Task {
                /// Update activity info
                var contentState = activity.content.state
                contentState.restStartTime = newRestStartTime
                contentState.restIntervals = newRestIntervals
                await activity.update(.init(state: contentState, staleDate: nil))
            }
        }
        
        /// Send message to Watch
        sendWatchMessage(message: ["state": newState.rawValue,
                                   "restStartTime": Date.now,
                                   "restIntervals": 0
                                  ])
    }
    
    /// Next Set
    func nextSet() {
        let currentTime = Date.now
        
        /// indexOfSet increased
        let newState: TrainingSessionState = .resting
        let newSetNumber = exerciseSetIndex + 1
        let newRestIntervals = currentExercise?.restIntevals ?? 0
        let newSetsProgress = Double(newSetNumber) / Double(currentExercise?.sets ?? 0)
        
        /// Create new rest time frame and set `startTime`
        currentRestTimeFrame = RestTimeFrame(startTime: currentTime)
        
        /// Schedule a rest time notification
        scheduleNotification(timeInterval: newRestIntervals)
        
        DispatchQueue.main.async {
            self.state = newState
            self.exerciseSetIndex = newSetNumber
            self.restStartTime = currentTime
            self.restIntervals = newRestIntervals
            self.exerciseSetCompletionProgress = newSetsProgress
        }
        
        /// Update Live Activity
        if let activity = Activity<TrainingSessionAttributes>.activities.first {
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
        
        /// Send message to Watch
        sendWatchMessage(message: ["state": newState.rawValue,
                                   "indexOfSet": newSetNumber,
                                   "currentSetsProgress": newSetsProgress,
                                   "restStartTime": currentTime,
                                   "restIntervals": newRestIntervals
                                  ])
    }
    
    /// Next Exericse
    func nextExercise() {
        /// Update current exercise/set progress
        let completedSetsProgress = 1.0
        DispatchQueue.main.async {
            self.exerciseSetCompletionProgress = completedSetsProgress
            
            /// Update Live Activity
            if let activity = Activity<TrainingSessionAttributes>.activities.first {
                Task {
                    /// Update activity info
                    var contentState = activity.content.state
                    contentState.currentSetsProgress = completedSetsProgress
                    await activity.update(.init(state: contentState, staleDate: nil))
                }
            }
            
            /// Send message to Watch
            self.sendWatchMessage(message: ["currentSetsProgress": completedSetsProgress])
        }
        
        /// Go to next arranged exercise
        let newState: TrainingSessionState = .resting
        let newStage = sessionStage + 1
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
        let newProgress = Double(newStage) / Double(exerciseCount)
        
        /// Schedule rest time notification
        scheduleNotification(timeInterval: newRestIntervals)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.state = newState
            self.sessionStage = newStage
            self.currentExercise = newExercise
            self.exerciseSetIndex = newIndexOfSet
            self.restStartTime = newRestStartTime
            self.restIntervals = newRestIntervals
            self.exerciseSetCompletionProgress = newSetsProgress
            self.sessionProgress = newProgress
            
            /// Update Live Activity
            if let activity = Activity<TrainingSessionAttributes>.activities.first {
                Task {
                    /// Update activity info
                    var contentState = activity.content.state
                    contentState.currentExerciseID = newExercise.id.uuidString
                    contentState.currentExerciseName = newExercise.exercise.name
                    contentState.totoalProgress = newProgress
                    contentState.indexOfSet = newIndexOfSet
                    contentState.currentSetsProgress = newSetsProgress
                    contentState.weight = newExercise.weight
                    contentState.weightUnit = newExercise.weightUnit
                    contentState.repetition = newExercise.repetitions
                    contentState.restStartTime = newRestStartTime
                    contentState.restIntervals = newRestIntervals
                    
                    await activity.update(.init(state: contentState, staleDate: nil))
                }
            }
            
            /// Send message to Watch
            self.sendWatchMessage(message: ["state": newState.rawValue,
                                            "currentExerciseID": newExercise.id.uuidString,
                                            "currentExerciseName": newExercise.exercise.name,
                                            "totoalProgress": newProgress,
                                            "indexOfSet": newIndexOfSet,
                                            "currentSetsProgress": newSetsProgress,
                                            "weight": newExercise.weight,
                                            "weightUnit": newExercise.weightUnit,
                                            "repetitions": newExercise.repetitions,
                                            "restStartTime": newRestStartTime,
                                            "restIntervals": newRestIntervals
                                           ])
        }
    }
}

// MARK: Watch Connectivity
extension TrainingSessionManager {
    func sendWatchMessage(message: [String: Any]) {
        guard WCSession.default.isReachable else { return }
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
}

// MARK: Live Activity
extension TrainingSessionManager {
    /// Add live activity
    func addLiveAcitvity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled, let firstExercise = currentExercise else { return }
        
        let trainingSessionAttributes = TrainingSessionAttributes()
        contentState = TrainingSessionAttributes.ContentState(currentExerciseID: firstExercise.id.uuidString,
                                                              currentExerciseName: firstExercise.exercise.name,
                                                              weight: firstExercise.weight,
                                                              weightUnit: firstExercise.weightUnit,
                                                              repetition: firstExercise.repetitions,
                                                              startTime: startTime ?? .now,
                                                              restStartTime: nil,
                                                              restIntervals: nil,
                                                              indexOfSet: exerciseSetIndex,
                                                              currentSetsProgress: exerciseSetCompletionProgress,
                                                              totoalProgress: 0,
                                                              completionType: -1)
        
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
    
    /// Remove all existing live activity
    func removeExistingAcitvity() {
        Task {
           for activity in Activity<TrainingSessionAttributes>.activities {
                let finalState = activity.content.state
                await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
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
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "soundEffect.m4a"))
                content.interruptionLevel = .timeSensitive
                
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

// MARK: Audio
extension TrainingSessionManager {
    func prepareSoundEffect() {
        guard let soundURL = Bundle.main.url(forResource: "soundEffect", withExtension: "m4a") else { return }
             
        do {
           audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
           audioPlayer?.prepareToPlay()
        } catch {
           fatalError("Error initializing audio player: \(error.localizedDescription)")
        }
    }
}
