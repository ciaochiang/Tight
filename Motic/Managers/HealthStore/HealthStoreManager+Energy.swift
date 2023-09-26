//
//  HealthStoreManager+Energy.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/23.
//

import HealthKit

extension HealthStoreManager {
    func getAvgMETs(from workout: HKWorkout) -> Double? {
        guard let quantity = workout.metadata?["HKAverageMETs"] as? HKQuantity else { return nil }
        
        let unit = HKUnit.kilocalorie().unitDivided(by: HKUnit.gramUnit(with: .kilo)).unitDivided(by: .hour())
        let value = quantity.doubleValue(for: unit)
        dependency.logger.log("Avg. METs: \(value)", level: .info)
        
        return value
    }
  
    func getBasalEnergyBurnedSamples(from workout: HKWorkout) async throws -> [ChartData<Double>] {
        // Define the type.
        let basalEnergyBurned = HKQuantityType(.basalEnergyBurned)
        let predicate = HKQuery.predicateForObjects(from: workout)

        // Create the descriptor.
        let descriptor = HKSampleQueryDescriptor(
            predicates:[.quantitySample(type: basalEnergyBurned, predicate: predicate)],
            sortDescriptors: [],
            limit: HKObjectQueryNoLimit)

        let results = try await descriptor.result(for: healthStore)

        let collection = results.map {
            ChartData<Double>(date: $0.startDate,
                              value: $0.quantity.doubleValue(for: HKUnit.smallCalorie()))
            
        }
        
        return collection.sorted(by: { $0.date < $1.date })
    }
    
    
    func getActiveEnergyBurnedSamples(from workout: HKWorkout) async throws -> [ChartData<Double>] {
        // Define the type.
        let activeEnergyBurned = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForObjects(from: workout)

        // Create the descriptor.
        let descriptor = HKSampleQueryDescriptor(
            predicates:[.quantitySample(type: activeEnergyBurned, predicate: predicate)],
            sortDescriptors: [],
            limit: HKObjectQueryNoLimit)

        let results = try await descriptor.result(for: healthStore)

        let collection = results.map {
            ChartData<Double>(date: $0.startDate,
                              value: $0.quantity.doubleValue(for: HKUnit.smallCalorie()))
            
        }
        
        return collection.sorted(by: { $0.date < $1.date })
    }
}
