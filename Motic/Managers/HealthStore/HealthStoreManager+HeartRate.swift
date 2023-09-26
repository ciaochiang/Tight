//
//  HealthStoreManager+HeartRate.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import HealthKit

// MARK: Heart Rate Function
extension HealthStoreManager {
    func startObserveHeartRateSamples() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let heartRateQuantitySample = results?.first as? HKQuantitySample {
                let heartRateSample = HeartRateSample<HKQuantitySample, Double>(sample: heartRateQuantitySample)
                self.latestHeartRate = heartRateSample
            }
        }
        
        healthStore.execute(query)
    }

    func getHeartRateZoneDurations(from heartRates: [ChartData<Double>], zones: [Zone]) -> [Zone] {
        // Make array is mutable
        var zones = zones
        
        var previousSample: ChartData<Double>? = nil
        for sample in heartRates {
            if let previusStartDate = previousSample?.date {
                let heartRate = Int(sample.value)
                if let index = zones.firstIndex(where: { $0.heartRateRange.contains(heartRate) }) {
                    let duration = sample.date.timeIntervalSince(previusStartDate)
                    var zone = zones[index]
                    zone.duration += duration
                    zones[index] = zone
                }
            }
            previousSample = sample
        }
        
        dependency.logger.log("Zones: \(zones)", level: .info)
        return zones
    }
    
    
    func getHearRateSamples(from workout: HKWorkout) async throws -> [ChartData<Double>] {
        // Define the type.
        let heartRate = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForObjects(from: workout)

        // Create the descriptor.
        let descriptor = HKSampleQueryDescriptor(
            predicates:[.quantitySample(type: heartRate, predicate: predicate)],
            sortDescriptors: [],
            limit: HKObjectQueryNoLimit)

        let results = try await descriptor.result(for: healthStore)

        return results.map {
            ChartData<Double>(date: $0.startDate,
                              value: $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
            
        }
    }
    
    func getAverage(by dataSet: [ChartData<Double>]) -> Double {
        let sum = dataSet.reduce(0.0) { $0 + $1.value }
        return sum / Double(dataSet.count)
    }
    
    // MARK: Deprecated
//    func getAvgHeartRate(from workout: HKWorkout, _completion: @escaping (Double, Error?) -> ()) {
//      guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
//      let readTypes: Set<HKObjectType> = [heartRateType]
//      let predicate = HKQuery.predicateForObjects(from: workout)
//
//      healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
//        if success {
//          let query = HKStatisticsQuery(quantityType: heartRateType,
//                                        quantitySamplePredicate: predicate,
//                                        options: .discreteAverage) { (query, result, error) in
//            if let result = result, let averageHeartRate = result.averageQuantity() {
//              // The averageHeartRate variable now contains the average heart rate value
//              let beatsPerMinute = averageHeartRate.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
//              self.dependency.logger.log("Average Heart Rate: \(beatsPerMinute) bpm", level: .info)
//              _completion(beatsPerMinute, nil)
//            } else {
//              if let error = error {
//                self.dependency.logger.log("Error calculating average heart rate: \(error.localizedDescription)", level: .error)
//                _completion(0, error)
//              }
//            }
//          }
//
//          self.healthStore.execute(query)
//        }
//      }
//    }
    
}
