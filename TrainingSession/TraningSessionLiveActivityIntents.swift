//
//  TraningSessionLiveActivityIntents.swift
//  TrainingSessionExtension
//
//  Created by Ciao Chiang on 2024/2/1.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct CompleteSet: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "Complete Current Exercise"
    static var description = IntentDescription("Mark current exercise as completed and start rest")
    
    @Parameter(title: "Exercise ID")
    var id: String
    
    init() {
        
    }
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        TrainingSessionManager.shared.completeCurrentSet(exerciseID: id)
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SkipRest: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "Skip Resting"
    static var description = IntentDescription("Skip resting and go to next set")
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        TrainingSessionManager.shared.endRest()
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct StopTrainingSession: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "Stop Training Session"
    static var description = IntentDescription("Stop training session and reset session")
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        TrainingSessionManager.shared.endSession()
        return .result()
    }
}
