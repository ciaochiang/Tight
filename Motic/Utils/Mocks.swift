//
//  Mocks.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/22.
//

import Foundation
import HealthKit
import CoreLocation

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
    
    
    static func createMockLocations(activityId: String) -> [Location] {
        let clLocations: [CLLocation] = [
            CLLocation(latitude: 37.7802, longitude: -122.4848),
            CLLocation(latitude: 37.7804, longitude: -122.4851),
            CLLocation(latitude: 37.7808, longitude: -122.4847),
            CLLocation(latitude: 37.7812, longitude: -122.4843),
            CLLocation(latitude: 37.7815, longitude: -122.4839),
            CLLocation(latitude: 37.7810, longitude: -122.4833),
            CLLocation(latitude: 37.7806, longitude: -122.4837),
            CLLocation(latitude: 37.7802, longitude: -122.4841),
            CLLocation(latitude: 37.7802, longitude: -122.4848)
        ]
        
        let locations: [Location] = clLocations.map { clLocation in
            Location(activityId: activityId, location: clLocation)
        }
        return locations
    }
}

extension Mocks {
    static var coreDataManager: CoreDataManager {
        let dependency = CoreDataManagerDependencyImp(logger: CustomLogger())
        return CoreDataManager(dependency: dependency)
    }
    
    static var wearableDeviceManager: WearableDeviceManager {
        return WearableDeviceManager(logger: CustomLogger())
    }
    
    static var activitySessionManager: ActivitySessionManager {
        return ActivitySessionManager.shared
    }
    
    static var experimentProvider: ExperiementsProvider {
        return ExperiementsProvider()
    }
}
