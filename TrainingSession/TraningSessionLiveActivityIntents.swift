//
//  TraningSessionLiveActivityIntents.swift
//  TrainingSessionExtension
//
//  Created by Ciao Chiang on 2024/2/1.
//

import Foundation
import AppIntents

extension Notification.Name {
    static let intentComplete = Notification.Name("LiveActivityIntentComplete")
    static let intentSkip = Notification.Name("LiveActivityIntentSkip")
    static let intentStop = Notification.Name("LiveActivityIntentStop")
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct CompleteSet: LiveActivityIntent {
    static var title: LocalizedStringResource = "Complete Current Exercise"
    static var description = IntentDescription("Mark current exercise as completed and start rest")
    
    @Parameter(title: "Exercise ID")
    var exerciseID: String
    
    init() {
        
    }
    
    init(exerciseID: String) {
        self.exerciseID = exerciseID
    }
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        NotificationCenter.default.post(name: .intentComplete, object: nil, userInfo: ["exerciseID": exerciseID])
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SkipRest: LiveActivityIntent {
    static var title: LocalizedStringResource = "Skip Resting"
    static var description = IntentDescription("Skip resting and go to next set")
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        NotificationCenter.default.post(name: .intentSkip, object: nil)
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct StopTrainingSession: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Training Session"
    static var description = IntentDescription("Stop training session and reset session")
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        NotificationCenter.default.post(name: .intentStop, object: nil)
        return .result()
    }
}
