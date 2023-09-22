//
//  HealthStoreManager+Distance.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/23.
//

import HealthKit

extension HealthStoreManager {
  func getTotalDistanceMeters(workout: HKWorkout) -> Double {
    var distanceMeters: Double = 0
    if let totalDistanceMeters = workout.totalDistance?.doubleValue(for: HKUnit.meter()) {
      distanceMeters = totalDistanceMeters
    } else if let quantity = workout.metadata?["HKIndoorBikeDistance"] as? HKQuantity {
      let totalDistanceMeters = quantity.doubleValue(for: HKUnit.meter())
      distanceMeters = totalDistanceMeters
    }
    
    return distanceMeters
  }
  
  func getAvgSpeedPerHour(duration: Double, totalDistanceMeters: Double) -> Double {
    let avgSpeed = totalDistanceMeters / duration
    return avgSpeed * 3600
  }
  
  func formattedTotalDistance(meters: Double) -> String {
    // Use integer division to get kilometers and modulus operator for remaining meters
    let kilometers = Int(meters / 1000)
    let meters = Int(meters.truncatingRemainder(dividingBy: 1000))

    // Create a formatted string
    var formattedDistance = ""
    if kilometers > 0 {
      formattedDistance = "\(kilometers) km"
    }
    
    if meters > 0 {
      if !formattedDistance.isEmpty {
          formattedDistance += " "
      }
      formattedDistance += "\(meters) m"
    }
    
    return formattedDistance
  }
  
  func getAllCyclingDistanceSamples(workout: HKWorkout, _completion: @escaping ([ChartData<Double>]) -> ()) {
    guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling) else { return }
    let predicate = HKQuery.predicateForObjects(from: workout)

    var data: [ChartData<Double>] = []
    let readTypes: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .distanceCycling)!]
    healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
      if success {
        let distanceQuery = HKSampleQuery(sampleType: distanceType,
                                          predicate: predicate,
                                          limit: HKObjectQueryNoLimit,
                                          sortDescriptors: nil) { (query, results, error) in
          if let distanceSamples = results as? [HKQuantitySample] {
            for sample in distanceSamples {
              let distance = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
              let timestamp = sample.startDate
              let sample = ChartData<Double>(date: timestamp, value: distance)
              data.append(sample)
            }
            self.dependency.logger.log("All Distance Samples: \(data)", level: .info)
            _completion(data)
          } else {
            if let error = error {
              self.dependency.logger.log("Error fetching distance samples: \(error.localizedDescription)", level: .error)
            }
            _completion(data)
          }
        }
        
        self.healthStore.execute(distanceQuery)
      }
    }
  }
}
