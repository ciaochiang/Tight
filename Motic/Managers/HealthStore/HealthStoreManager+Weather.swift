//
//  HealthStoreManager+Weather.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/23.
//

import HealthKit

extension HealthStoreManager {
  func getWeatherTemperatureCelsius(from workout: HKWorkout) -> Double? {
    if let quantity = workout.metadata?["HKWeatherTemperature"] as? HKQuantity {
      let unit = HKUnit.degreeCelsius()
      let value = quantity.doubleValue(for: unit)
      dependency.logger.log("Activtiy Weather Temperature: \(value)", level: .info)
      return value
    }
    
    return nil
  }
}
