//
//  HealthStoreManager+Activity.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/26.
//

import HealthKit

struct Activity: Identifiable {
    let id: String = UUID().uuidString
    let workoutActivityType: HKWorkoutActivityType
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let totalEnergyBurned: HKQuantity?
}

extension HealthStoreManager {
//    func getActivties(from start: Date, to end: Date) async throws -> [Activity] {
//        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
//
//        // Create the descriptor.
//        let descriptor = HKSampleQueryDescriptor(
//            predicates:[.workout(predicate)],
//            sortDescriptors: [],
//            limit: HKObjectQueryNoLimit)
//
//        let results = try await descriptor.result(for: healthStore)
//        
//        let collection = results.map { _ in
//            Activity(workoutActivityType: result.workoutActivityType,
//                     startDate: result.startDate,
//                     endDate: result.endDate,
//                     duration: result.duration,
//                     totalEnergyBurned: result.totalEnergyBurned)
//        }
//        
//        return collection.sorted(by: { $0.endDate > $1.endDate })
//    }
}
