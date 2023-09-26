//
//  HealthStoreManager+Activity.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/26.
//

import HealthKit

extension HealthStoreManager {
    func getActivties(from start: Date, to end: Date) async throws -> [HKWorkout] {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        // Create the descriptor.
        let descriptor = HKSampleQueryDescriptor(
            predicates:[.workout(predicate)],
            sortDescriptors: [],
            limit: HKObjectQueryNoLimit)

        let results = try await descriptor.result(for: healthStore)
        
        return results.sorted(by: { $0.endDate > $1.endDate })
    }
}
