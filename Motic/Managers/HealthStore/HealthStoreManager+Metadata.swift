//
//  HealthStoreManager+Metadata.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/23.
//

import HealthKit

extension HealthStoreManager {
  func getTimezone(from workout: HKWorkout) -> TimeZone? {
    if let value = workout.metadata?["HKTimeZone"] as? String,
        let timezone = TimeZone(identifier: value) {
      dependency.logger.log("Activiy Time Zone: \(timezone)", level: .info)
      return timezone
    }
    
    return nil
  }
}
