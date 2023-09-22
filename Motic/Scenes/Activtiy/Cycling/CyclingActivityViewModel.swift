//
//  CyclingActivityViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/20.
//

import SwiftUI
import HealthKit

protocol CyclingActivityViewModelDependency {
  var logger: Logger { get }
}

class CyclingActivityViewModelDependencyImp: CyclingActivityViewModelDependency {
  var logger: Logger
  
  init(logger: Logger) {
    self.logger = logger
  }
}

class CyclingActivityViewModel: ObservableObject {
  var dependency: CyclingActivityViewModelDependency
  @Published var healthStoreManager: HealthStoreManager
  var workout: HKWorkout
  @Published var workoutType: WorkoutActivityType
  @Published var duraiton: TimeInterval
  @Published var totalDistanceMeters: Double
  @Published var avgHeartRate: Double = 0
  @Published var avgSpeedPerHour: Double = 0
  
  init(dependency: CyclingActivityViewModelDependency,
       healthStoreManager: HealthStoreManager,
       workout: HKWorkout) {
    self.dependency = dependency
    _healthStoreManager = Published(wrappedValue: healthStoreManager)
    self.workout = workout
    self.duraiton = workout.duration
    self.totalDistanceMeters = healthStoreManager.getTotalDistanceMeters(workout: workout)
    self.workoutType = WorkoutActivityType(activityType: workout.workoutActivityType)

    // After initialization
    self.healthStoreManager.getAvgHeartRateSamples(workout: workout)
    self.avgSpeedPerHour = healthStoreManager.getAvgSpeedPerHour(duration: self.duraiton,
                                                                 totalDistanceMeters: self.totalDistanceMeters)
    
    // Get avg. heart rate
    healthStoreManager.getAvgHeartRate(from: workout) { heartRate, error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      } else {
        DispatchQueue.main.async {
          self.avgHeartRate = heartRate
        }
      }
    }
  }
  
  func getFormattedDuration(duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.hour, .minute, .second]
    
    if let formattedString = formatter.string(from: duration) {
        return formattedString
    } else {
        return "0s" // Default value or an error message
    }
  }
}
