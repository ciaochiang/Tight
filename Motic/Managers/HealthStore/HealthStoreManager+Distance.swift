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
    
    func getElavationAscendedMeters(from workout: HKWorkout) -> Double? {
        guard let quantity = workout.metadata?["HKElevationAscended"] as? HKQuantity else { return nil }
        
        let unit = HKUnit.meter()
        let value = quantity.doubleValue(for: unit)
        dependency.logger.log("Elavation Ascended: \(value)", level: .info)
        
        return value
    }
    
    func getDistanceSamples(from workout: HKWorkout) async throws -> [ChartData<Double>] {
        // Define the type.
        let distance = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForObjects(from: workout)

        // Create the descriptor.
        let descriptor = HKSampleQueryDescriptor(
            predicates:[.quantitySample(type: distance, predicate: predicate)],
            sortDescriptors: [],
            limit: HKObjectQueryNoLimit)

        let results = try await descriptor.result(for: healthStore)

        let collection = results.map {
            ChartData<Double>(date: $0.startDate,
                              value: $0.quantity.doubleValue(for: HKUnit.meter()))
            
        }
        
        return collection.sorted(by: { $0.date < $1.date })
    }
}
