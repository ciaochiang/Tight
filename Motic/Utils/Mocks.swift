//
//  Mocks.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/22.
//

import Foundation
import HealthKit

class Mocks {
    static var logger: CustomLogger {
        return CustomLogger(subSystem: .dev)
    }
    
    static var mockHealthStoreManager: HealthStoreManager {
        let logger = CustomLogger(subSystem: .dev)
        let dependency = HealthStoreManagerDependencyImp(logger: logger)
        return HealthStoreManager(dependency: dependency)
    }
  
  static var mockActivity: Activity {
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

      return Activity(workoutActivityType: workoutType, startDate: startDate, endDate: endDate, duration: 0, totalEnergyBurned: energyBurned, workout: workout)
  }
    
    static var chartDataSet: [ChartData<Double>] {
        let data: [ChartData<Double>] = [
            .init(date: Date.from(year: 2023, month: 9, day: 1), value: 60),
            .init(date: Date.from(year: 2023, month: 9, day: 2), value: 40),
            .init(date: Date.from(year: 2023, month: 9, day: 3), value: 200),
            .init(date: Date.from(year: 2023, month: 9, day: 4), value: 162),
            .init(date: Date.from(year: 2023, month: 9, day: 5), value: 240),
            .init(date: Date.from(year: 2023, month: 9, day: 6), value: 45),
            .init(date: Date.from(year: 2023, month: 9, day: 7), value: 68),
            .init(date: Date.from(year: 2023, month: 9, day: 8), value: 91)
        ]
        
        return data
    }
}
