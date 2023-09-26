//
//  HealthStoreManager+Energy.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/23.
//

import HealthKit

extension HealthStoreManager {
  func getAvgMETs(from workout: HKWorkout) -> Double? {
    if let quantity = workout.metadata?["HKAverageMETs"] as? HKQuantity {
      let unit = HKUnit.kilocalorie().unitDivided(by: HKUnit.gramUnit(with: .kilo)).unitDivided(by: .hour())
      let value = quantity.doubleValue(for: unit)
      dependency.logger.log("Avg. METs: \(value)", level: .info)
      return value
    }
    
    return nil
  }
  
  func getBasalEnergyBurnedSamples(from workout: HKWorkout, _completion: @escaping ([ChartData<Double>]?, Error?) -> ()) {
    guard let quantityType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else { return }
    let predicate = HKQuery.predicateForObjects(from: workout)

    var data: [ChartData<Double>] = []
    let readTypes: Set<HKObjectType> = [quantityType]
    healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
      if success {
        let query = HKSampleQuery(sampleType: quantityType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { (query, results, error) in
          if let energySamples = results as? [HKQuantitySample] {
            for sample in energySamples {
                let distance = sample.quantity.doubleValue(for: HKUnit.smallCalorie())
                let sample = ChartData<Double>(date: sample.startDate, value: distance)
                data.append(sample)
            }
            self.dependency.logger.log("All Basal Energy Burned Samples: \(data)", level: .info)
            _completion(data, nil)
          } else {
            if let error = error {
              self.dependency.logger.log("Error fetching basal energy burned samples: \(error.localizedDescription)", level: .error)
            }
            _completion(nil, error)
          }
        }
        
        self.healthStore.execute(query)
      }
    }
  }
    
  func getActiveEnergyBurnedSamples(from workout: HKWorkout, _completion: @escaping ([ChartData<Double>]?, Error?) -> ()) {
    guard let quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
    let predicate = HKQuery.predicateForObjects(from: workout)

    var data: [ChartData<Double>] = []
    let readTypes: Set<HKObjectType> = [quantityType]
    healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
      if success {
        let query = HKSampleQuery(sampleType: quantityType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { (query, results, error) in
          if let energySamples = results as? [HKQuantitySample] {
            for sample in energySamples {
                let distance = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                let sample = ChartData<Double>(date: sample.startDate, value: distance)
                data.append(sample)
            }
            self.dependency.logger.log("All Active Energy Burned Samples: \(data)", level: .info)
            _completion(data, nil)
          } else {
            if let error = error {
              self.dependency.logger.log("Error fetching active energy burned samples: \(error.localizedDescription)", level: .error)
            }
            _completion(nil, error)
          }
        }
        
        self.healthStore.execute(query)
      }
    }
  }
  
  func getAvgValue(from data: [ChartData<Double>]?) -> Double {
    guard let data = data else { return 0 }
    
    let sum = data.reduce(0.0) { $0 + $1.value }
    return sum / Double(data.count)
  }
}
