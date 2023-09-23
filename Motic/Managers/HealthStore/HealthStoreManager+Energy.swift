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
}

// MARK: Elevation
extension HealthStoreManager {
  func getElavationAscendedMeters(from workout: HKWorkout) -> Double? {
    if let quantity = workout.metadata?["HKElevationAscended"] as? HKQuantity {
      let unit = HKUnit.meter()
      let value = quantity.doubleValue(for: unit)
      dependency.logger.log("Elavation Ascended: \(value)", level: .info)
      return value
    }
    
    return nil
  }
}
