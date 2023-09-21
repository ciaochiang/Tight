//
//  Mocks.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/22.
//

import Foundation
import HealthKit

class Mocks {
  static var mockHealthStoreManager: HealthStoreManager {
    let dependency = HealthStoreManagerDependencyImp(logger: Logger(configuration: AppConfiguration.loggerConfig))
    return HealthStoreManager(dependency: dependency)
  }
  
  static var mockWorkout: HKWorkout {
      // Define workout parameters
      let startDate = Date() // Start date of the workout
      let endDate = startDate.addingTimeInterval(3600) // End date (1 hour later in this example)
      let workoutType = HKWorkoutActivityType.running // Replace with your desired workout type
      let energyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: 300) // Energy burned during the workout
      let distance = HKQuantity(unit: .mile(), doubleValue: 3.5) // Distance covered during the workout
      let workoutEvents: [HKWorkoutEvent] = [] // You can define workout events if needed

      // Create the workout
      let workout = HKWorkout(
          activityType: workoutType,
          start: startDate,
          end: endDate,
          workoutEvents: workoutEvents,
          totalEnergyBurned: energyBurned,
          totalDistance: distance,
          metadata: nil
      )

      return workout
  }
}
