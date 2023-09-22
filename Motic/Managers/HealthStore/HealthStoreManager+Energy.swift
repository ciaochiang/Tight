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
      let kilocaloriePerHourPerKilogramUnit = HKUnit.kilocalorie().unitDivided(by: HKUnit.gramUnit(with: .kilo)).unitDivided(by: .hour())
      let value = quantity.doubleValue(for: kilocaloriePerHourPerKilogramUnit)
      dependency.logger.log("Avg. METs: \(value)", level: .info)
      return value
    }
    
    return nil
  }
}
