//
//  Mocks.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/22.
//

import Foundation
import HealthKit
import CoreLocation

class Mocks {
    static var logger: CustomLogger {
        return CustomLogger(subSystem: .dev)
    }
    
    static var mockArrangedExercise: ArrangedExercise {
        return .init(exercise: .benchPress, repetitions: 0, sets: 0, weight: 0, weightUnit: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false, startTime: nil, endTime: nil)
    }
    
    static var mockPlan: Plan {
        return .init(name: "Preview", startDate: .init(), repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: false)
    }

}

extension Mocks {
    static var experimentProvider: ExperiementsProvider {
        return ExperiementsProvider()
    }
}
