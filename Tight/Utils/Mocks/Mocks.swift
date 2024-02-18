//
//  Mocks.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/22.
//

import Foundation
import HealthKit
import CoreLocation
import SwiftData

class Mocks {
    static var logger: TTLogger {
        return TTLogger(subSystem: .dev)
    }
    
    static var mockArrangedExercise: ArrangedExercise {
        return .init(exercise: .benchPress, repetitions: 0, sets: 0, weight: 0, weightUnit: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false, startTime: nil, endTime: nil)
    }
    
    static var mockPlan: Plan {
        return .init(name: "Preview", startDate: .init(), repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: false)
    }
    
    static var trainingContent: TrainingSessionContent {
        return .init(state: .training, 
                     liveActivityID: "",
                     currentExercise: Mocks.mockArrangedExercise,
                     exerciseID: nil,
                     startTime: .now,
                     exerciseCount: 4,
                     indexOfExercise: 2,
                     totalProgress: 30,
                     indexOfSet: 1,
                     setsProgress: 50,
                     restStartTime: nil,
                     restInterval: 0)
    }
    
    static let container: ModelContainer = {
        let schema = Schema([ArrangedExercise.self, Plan.self])
        let configuratin = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let container = try! ModelContainer(
            for: schema,
            migrationPlan: TightMigrationPlan.self,
            configurations: [configuratin])
        return container
    }()

}

extension Mocks {
    static var experimentProvider: ExperiementsProvider {
        return ExperiementsProvider()
    }
}
